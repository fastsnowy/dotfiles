function github-fuzzy-switch() {
    local pr_number=$(gh pr list | fzf --height 80% --layout=reverse --preview "echo {} | awk '{print \$1}' | xargs gh pr view" --ansi | awk '{print $1}')
    if [ -n "$pr_number" ]; then
        gh pr checkout "$pr_number"
    fi
}

function fzf-bat() {
    fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
}

function broot-bat() {
    broot --outcmd 'fzf --preview "bat --style=numbers --color=always --line-range :500 {}"'
}
