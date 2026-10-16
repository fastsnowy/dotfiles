# Dotfiles

![](https://i.imgur.com/i2uPF96.webp)

## Requirements

- macOS / Debian / Ubuntu
- zsh
- nerd-fonts

## Installation

```bash
sh -c "$(curl -fsSL https://get.chezmoi.io)" -- init --apply fastsnowy
mise install
```

macOS restores Homebrew packages, apps, and fonts from `~/.Brewfile`. Open a new zsh session before running `mise install`.

## tools

- Homebrew ([Brewfile](dot_Brewfile))
- cargo
- mise
- starship
- sheldon
- eza
- zabrze
- fzf
- zoxide
- GitHub CLI

## Check

```bash
python3 tests/validate.py
actionlint
```

GitHub Actions checks Linux and macOS. Package downloads and compilation are excluded from the tests.
