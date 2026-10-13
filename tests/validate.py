#!/usr/bin/env python3
"""Validate dotfiles without changing the real home or installing packages."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1]
CHEZMOI = shutil.which('chezmoi')
ZSH = shutil.which('zsh')


def run(args, **kwargs):
    return subprocess.run(args, check=True, text=True, capture_output=True, **kwargs)


class DotfilesTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='dotfiles-test-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / 'home'
        self.home.mkdir()
        config = self.root / 'chezmoi.toml'
        config.write_text('')
        self.chezmoi = [CHEZMOI, '--source', str(SOURCE), '--destination', str(self.home),
                        '--config', str(config), '--cache', str(self.root / 'cache'),
                        '--persistent-state', str(self.root / 'state.boltdb'), '--no-tty']

    def render(self, template, platform):
        data = json.dumps({'chezmoi': {'os': platform}})
        return run(self.chezmoi + ['--override-data', data, 'execute-template',
                                   '--file', str(template)]).stdout

    def test_templates_and_shell_syntax(self):
        templates = sorted(SOURCE.rglob('*.tmpl'))
        self.assertTrue(templates)
        for platform in ('darwin', 'linux', 'windows'):
            for template in templates:
                with self.subTest(platform=platform, template=template.name):
                    rendered = self.render(template, platform)
                    if template.name.endswith('.sh.tmpl'):
                        run(['bash', '-n'], input=rendered)
                        if platform == 'windows':
                            self.assertEqual(rendered.strip(), '')
        for script in [SOURCE / 'dot_zshenv', SOURCE / 'dot_zprofile', SOURCE / 'dot_zshrc',
                       *sorted((SOURCE / 'dot_config/zsh').rglob('*.zsh'))]:
            run([ZSH, '-n', str(script)])

    def test_apply_and_verify(self):
        managed = run(self.chezmoi + ['managed', '--include=files']).stdout.splitlines()
        for name in ('README.md', 'tests/validate.py', '.github/workflows/ci.yaml'):
            self.assertNotIn(name, managed)
        self.assertIn('.config/mise/config.toml', managed)
        self.assertIn('.Brewfile', managed)
        self.assertIn('.agents/skills/yomiyasu/.claude-plugin/plugin.json', managed)
        self.assertIn('.agents/skills/yomiyasu/scripts/yomiyasu_lint.py', managed)
        run(self.chezmoi + ['apply', '--exclude=scripts'])
        run(self.chezmoi + ['verify', '--exclude=scripts'])
        # A second apply must leave the same desired state.
        run(self.chezmoi + ['apply', '--exclude=scripts'])
        run(self.chezmoi + ['verify', '--exclude=scripts'])
        self.assertFalse((self.home / 'README.md').exists())
        self.assertFalse((self.home / 'tests').exists())
        self.assertTrue(os.access(self.home / '.agents/skills/yomiyasu/scripts/yomiyasu_lint.py', os.X_OK))
        # Start a clean interactive shell before Cargo/mise/sheldon are installed.
        env = {'HOME': str(self.home), 'ZDOTDIR': str(self.home),
               'PATH': '/usr/bin:/bin', 'TERM': 'dumb'}
        result = run([ZSH, '-d', '-i', '-c', 'print -r -- ready'], env=env)
        self.assertEqual(result.stdout.strip(), 'ready')
        self.assertEqual(result.stderr, '')
        result = run([ZSH, '-d', '-f', '-c',
                      'path=(); source "$HOME/.config/zsh/defer/inline.zsh"; print -r -- ready'], env=env)
        self.assertEqual(result.stdout.strip(), 'ready')
        self.assertEqual(result.stderr, '')

    def test_nonlogin_shell_activates_mise_before_sheldon(self):
        run(self.chezmoi + ['apply', '--exclude=scripts'])
        binaries = self.home / '.local/bin'
        binaries.mkdir(parents=True)
        mise = binaries / 'mise'
        mise.write_text('#!/bin/sh\necho "export DOTFILES_MISE_ACTIVE=1"\n')
        sheldon = binaries / 'sheldon'
        sheldon.write_text('#!/bin/sh\n[ "$DOTFILES_MISE_ACTIVE" = 1 ] || exit 1\necho "print -r -- activated"\n')
        mise.chmod(0o755)
        sheldon.chmod(0o755)
        env = {'HOME': str(self.home), 'ZDOTDIR': str(self.home),
               'PATH': '/usr/bin:/bin', 'TERM': 'dumb'}
        result = run([ZSH, '-d', '-i', '-c', ':'], env=env)
        self.assertEqual(result.stdout.strip(), 'activated')
        self.assertEqual(result.stderr, '')

    def cargo_environment(self, curl_body):
        binaries = self.root / 'bin'
        binaries.mkdir()
        curl = binaries / 'curl'
        curl.write_text('#!/bin/sh\n' + curl_body)
        curl.chmod(0o755)
        return {'HOME': str(self.home), 'PATH': str(binaries) + ':/usr/bin:/bin',
                'DOTFILES_LOG': str(self.root / 'cargo.log')}

    def test_rust_install_is_noninteractive_and_reuses_cargo(self):
        installer = self.root / 'rustup.sh'
        installer.write_text('''#!/bin/sh
printf '%s\\n' "$*" > "$HOME/rustup.args"
mkdir -p "$HOME/.cargo/bin"
printf 'export PATH="%s/.cargo/bin:$PATH"\\n' "$HOME" > "$HOME/.cargo/env"
cat > "$HOME/.cargo/bin/cargo" <<'CARGO'
#!/bin/sh
printf '%s\\n' "$*" >> "$DOTFILES_LOG"
CARGO
chmod +x "$HOME/.cargo/bin/cargo"
''')
        env = self.cargo_environment('cat "' + str(installer) + '"\n')
        script = self.render(SOURCE / 'scripts/run_once_02_cargo.sh.tmpl', 'linux')
        run(['bash'], input=script, env=env)
        self.assertEqual((self.home / 'rustup.args').read_text().strip(),
                         '-y --profile minimal --no-modify-path')
        (self.root / 'bin/curl').write_text('#!/bin/sh\nexit 99\n')
        run(['bash'], input=script, env=env)
        self.assertEqual((self.root / 'cargo.log').read_text().splitlines(),
                         ['install --locked sheldon mise eza zabrze'] * 2)

    def test_failed_rust_download_stops_bootstrap(self):
        env = self.cargo_environment('exit 23\n')
        script = self.render(SOURCE / 'scripts/run_once_02_cargo.sh.tmpl', 'linux')
        result = subprocess.run(['bash'], input=script, env=env, text=True, capture_output=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.root / 'cargo.log').exists())


if __name__ == '__main__':
    if not CHEZMOI or not ZSH:
        raise SystemExit('Install chezmoi and zsh before running validation.')
    unittest.main(verbosity=2)
