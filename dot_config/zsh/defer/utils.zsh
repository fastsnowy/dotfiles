function github-fuzzy-switch() {
    local pr_number=$(gh pr list | fzf --height 80% --layout=reverse --preview "echo {} | awk '{print \$1}' | xargs gh pr view" --ansi | awk '{print $1}')
    if [ -n "$pr_number" ]; then
        gh pr checkout "$pr_number"
    fi
}
