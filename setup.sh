#!/bin/bash
function install_cargo {
    if [[ ! -d "$HOME/.cargo" ]]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source $HOME/.cargo/env
        echo -e "\e[36mInstalled rustup\e[m\n"
    fi
}

function install_sheldon {
    if ! command -v sheldon >/dev/null 2>&1; then
        cargo install sheldon
        echo -e "\e[36mInstalled sheldon\e[m\n"
    fi
}

function install_brew {
    if [ -z "$(command -v brew)" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        brew bundle
        echo -e "\e[36mInstalled homebrew\e[m\n"
    fi
}

function install_starship {
    if ! command -v starship >/dev/null 2>&1; then
        curl --proto '=https' --tlsv1.2 -sSf https://starship.rs/install.sh | sh -s -- -y
        echo -e "\e[36mInstalled starship\e[m\n"
    fi
}

function install_rtx {
    if ! command -v rtx >/dev/null 2>&1; then
        cargo install rtx-cli
        echo -e "\e[36mInstalled rtx-cli\e[m\n"
    fi
}

function install_rye {
    if ! command -v rye >/dev/null 2>&1; then
        curl -sSf https://rye-up.com/get | RYE_INSTALL_OPTION="--yes" bash
        echo -e "\e[36mInstalled rye\e[m\n"
    fi
}

function install_eza {
    if ! command -v eza >/dev/null 2>&1; then
        cargo install eza
        echo -e "\e[36mInstalled eza\e[m\n"
    fi
}

function installs {
    install_cargo
    install_sheldon
    install_starship
    install_rtx
    install_rye
    install_eza
}

function extra_installs {
    install_brew
}

# symlink
function symbolic_links {
    # backup
    echo -e "\e[36mBackup old files\e[m\n"
    if [[ -f ~/.zshrc ]]; then
        mv ~/.zshrc ~/.zshrc.bak
    fi
    if [[ -f ~/.config/starship.toml ]]; then
        mv ~/.config/starship.toml ~/.config/starship.toml.bak
    fi
    if [[ -f ~/.config/sheldon/plugins.toml ]]; then
        mv ~/.config/sheldon/plugins.toml ~/.config/sheldon/plugins.toml.bak
    fi
    echo -e "\e[36mBackup done\e[m\n"
    
    # symbolic links
    dotfiles_dir="$(cd "$(dirname "$0")" && pwd -P)"
    echo -e "\e[36mCreate symbolic links\e[m\n"
    ln -snf $dotfiles_dir/.config/zsh/.zshrc $HOME/.zshrc
    ln -snf $dotfiles_dir/.config/zsh/.zshenv $HOME/.zshenv
    # .configフォルダがない場合は作成
    if [[ ! -d "$HOME/.config" ]]; then
        mkdir -p $HOME/.config/sheldon
        mkdir -p $HOME/.config/zsh/defer
    fi
    ln -snf $dotfiles_dir/.config/starship/starship.toml $HOME/.config/starship.toml
    ln -snf $dotfiles_dir/.config/sheldon/plugins.toml $HOME/.config/sheldon/plugins.toml
    # $dotfiles_dir/.config/zsh/defer/以下のファイルを$HOME/.config/zsh/defer/以下にシンボリックリンクを作成
    for file in $dotfiles_dir/.config/zsh/defer/*; do
        ln -snf $file $HOME/.config/zsh/defer/$(basename $file)
    done

    echo -e "\e[36mCreate symbolic links done\e[m\n"
}


# コマンドライン引数を受け取るmain
function main {
    if [[ $1 == "-i" ]]; then
        installs
        symbolic_links
    elif [[ $1 == "-s" ]]; then
        symbolic_links
    elif [[ $1 == "-e" ]]; then
        extra_installs
    elif [[ $1 == "-a" ]]; then
        installs
        symbolic_links
    else
        echo -e "\e[31mInvalid argument\e[m\n"
    fi
}

main $1
