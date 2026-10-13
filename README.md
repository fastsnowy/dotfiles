# Dotfiles

Personal zsh and terminal settings managed with [chezmoi](https://www.chezmoi.io/), plus agent skills under `~/.agents/skills`.

## Requirements

- macOS with administrator access, or Debian/Ubuntu with `sudo` and `apt-get`
- `curl`, Git, and internet access for the initial bootstrap
- zsh and a Nerd Font (terminal settings use HackGen35 Console NF)

Windows bootstrap is not supported. Other Linux distributions can use the configuration files after installing dependencies manually.

## Installation

```sh
sh -c "$(curl -fsSL https://get.chezmoi.io)" -- init --apply fastsnowy
```

The `run_once` scripts install Homebrew dependencies on macOS or apt dependencies on Debian/Ubuntu, then install Rust if Cargo is missing and install sheldon, mise, eza, and zabrze. Downloads and installation failures stop the bootstrap. Existing Homebrew and Cargo installations are reused.

Open a new zsh session, then install the tools listed in `~/.config/mise/config.toml`:

```sh
mise install
```

This includes starship, GitHub CLI, zoxide, and development tools. Shell initialization skips optional commands until they are installed. Homebrew initialization is in `.zprofile`; mise activation is in `.zshrc` so it also runs in non-login interactive shells. Older distro versions of fzf use the packaged zsh integration files.

## Updating and editing

```sh
chezmoi diff
chezmoi apply
# Pull changes from GitHub and apply them:
chezmoi update
# Record an edited destination file in this repository:
chezmoi add ~/.zshrc
```

Repository-only files are excluded through `.chezmoiignore`. chezmoi also ignores dot-prefixed source directories such as `.github`. Existing unmanaged copies of README or other repository files in the home directory are not automatically deleted.

`run_once` scripts run again if their rendered content changes. To preview a change without executing installation scripts:

```sh
chezmoi apply --dry-run --verbose
```

## Validation and GitHub Actions

With chezmoi, zsh, Bash, and Python 3 installed, run from the repository root:

```sh
python3 tests/validate.py
actionlint
```

The Check workflow runs on every PR, pushes to `main`, and manual dispatches. It checks Linux and macOS templates, shell syntax, startup without optional tools, Rust bootstrap behavior using command stubs, and apply/verify in a temporary destination. Installation scripts are excluded from the apply test to avoid installing packages or modifying the runner's real home. Full package downloads and compilation are not covered by these tests.

A separate job lints all workflows with actionlint. Action versions are pinned to commits and Dependabot proposes monthly updates. The existing Release Drafter workflow maintains draft release notes and PR labels; publishing releases remains manual. Release Drafter stays on the compatible v6 configuration format to preserve the existing categories, version rules, and autolabeler.
