eval ". $HOME/.rye/env"
eval "$(mise activate zsh)"
eval "$(zabrze init --bind-keys)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
source <(fzf --zsh)
eval "$(zoxide init zsh)"