function install_cargo {
    if [[ ! -d "$HOME/.cargo" ]]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source $HOME/.cargo/env
        echo -e "\e[36mInstalled rustup\e[m\n"
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

function install_exa {
    if ! command -v exa >/dev/null 2>&1; then
        cargo install exa
        echo -e "\e[36mInstalled exa\e[m\n"
    fi
}

function installs {
    install_cargo
    install_brew
    install_starship
    install_rtx
    install_rye
    install_exa
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
    echo -e "\e[36mCreate symbolic links\e[m\n"
    ln -snf $HOME/dotfiles/.config/zsh/.zshrc $HOME/.zshrc
    ln -snf $HOME/dotfiles/.config/zsh/.zshenv $HOME/.zshenv
    ln -snf $HOME/dotfiles/.config/starship/starship.toml $HOME/.config/starship.toml
    ln -snf $HOME/dotfiles/.config/sheldon/plugins.toml $HOME/.config/sheldon/plugins.toml
    echo -e "\e[36mCreate symbolic links done\e[m\n"
}


function main {
    installs
    symbolic_links
}

main