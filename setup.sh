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

function install_mise {
    if ! command -v rtx >/dev/null 2>&1; then
        cargo install mise
        echo -e "\e[36mInstalled mise\e[m\n"
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
    install_starship
    install_mise
    install_eza
    install_sheldon
}

function extra_installs {
    install_brew
    install_rye
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


function main {
    echo "1) Install and create symbolic links（Recommended）"
    echo "2) Create symbolic links"
    echo "3) Install extras"
    echo "4) Install"
    echo "5) Exit"
    echo "Please enter your choice: "
    read choice

    case $choice in
        1)
            installs
            symbolic_links
            ;;
        2)
            symbolic_links
            ;;
        3)
            extra_installs
            ;;
        4)
            installs
            ;;
        5)
            exit 0
            ;;
        *)
            echo -e "\e[31mInvalid choice\e[m"
            ;;
    esac
}

main
