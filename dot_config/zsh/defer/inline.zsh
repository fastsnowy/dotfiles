if command -v zabrze >/dev/null 2>&1; then
    eval "$(zabrze init --bind-keys)"
fi
if command -v fzf >/dev/null 2>&1; then
    # fzf --zsh requires >= 0.48; Debian/Ubuntu may ship an older release.
    if fzf_init=$(fzf --zsh 2>/dev/null); then
        eval "$fzf_init"
    else
        for fzf_file in /usr/share/doc/fzf/examples/{key-bindings,completion}.zsh /usr/share/fzf/{key-bindings,completion}.zsh; do
            [[ -r "$fzf_file" ]] && source "$fzf_file"
        done
        unset fzf_file
    fi
    unset fzf_init
fi
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi
if command -v gh >/dev/null 2>&1; then
    eval "$(gh completion -s zsh)"
fi
