# glow >=2.0 drops ANSI colors when stdout isn't a tty (e.g. fzf preview):
# https://github.com/charmbracelet/glow/issues/654
# Keep a pinned 1.5.1 binary around (outside the mise-managed `glow` command,
# since its flat archive layout isn't picked up on PATH) just for this preview.
function _glow_bin() {
    local glow_bin
    glow_bin="$(mise where glow@1.5.1 2>/dev/null)/glow"
    if [ ! -x "$glow_bin" ]; then
        command -v mise >/dev/null 2>&1 && mise install glow@1.5.1 >/dev/null 2>&1
        glow_bin="$(mise where glow@1.5.1 2>/dev/null)/glow"
    fi
    [ -x "$glow_bin" ] || glow_bin="glow"
    print -r -- "$glow_bin"
}

function gps() {
    local glow_bin pr_number
    glow_bin="$(_glow_bin)"
    pr_number=$(gh pr list | fzf \
        --height 80% \
        --layout=reverse \
        --border \
        --ansi \
        --preview-window=right:60%:wrap \
        --preview-label ' PR ' \
        --preview "
            n=\$(printf '%s' {} | awk '{print \$1}')
            gh pr view \"\$n\" --json title,body,author,state,baseRefName,headRefName,url \
                --template \$'# {{.title}}\n\n**{{.state}}** · \`@{{.author.login}}\` · \`{{.headRefName}}\` → \`{{.baseRefName}}\`\n\n{{.url}}\n\n---\n\n{{.body}}\n' \
                | '${glow_bin}' -s dark -w \"\${FZF_PREVIEW_COLUMNS:-80}\"
        " | awk '{print $1}')
    if [ -n "$pr_number" ]; then
        gh pr checkout "$pr_number"
    fi
}

function _gps() {
    zle -I
    gps
    zle clear-screen
}

function fzf-bat() {
    fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
}

function broot-bat() {
    broot --outcmd 'fzf --preview "bat --style=numbers --color=always --line-range :500 {}"'
}

function ghq-fzf() {
    local ghq_root selected glow_bin

    ghq_root="$(ghq root)"
    glow_bin="$(_glow_bin)"

    selected=$(ghq list | while IFS= read -r repo; do
        printf '%s\t%s\n' $'\uf07b' "$repo"
    done | fzf \
        --height 80% \
        --layout=reverse \
        --border \
        --delimiter=$'\t' \
        --with-nth '{1} {2}' \
        --accept-nth=2 \
        --preview-label ' README ' \
        --preview "
            repo='${ghq_root}/'\$(printf '%s' {} | cut -f2)
            for f in README.md Readme.md readme.md; do
                if [ -f \"\$repo/\$f\" ]; then
                    '${glow_bin}' -s dark -w \"\${FZF_PREVIEW_COLUMNS:-80}\" \"\$repo/\$f\" < /dev/null
                    exit 0
                fi
            done
            echo 'No README.md found'
        " \
        --preview-window=right:60%:wrap \
        --ansi)
    
    if [ -n "$selected" ]; then
        cd "$(ghq root)/$selected"
    fi
    zle clear-screen
}

function _zi() {
    zi
    zle clear-screen
}

zle -N ghq-fzf
bindkey '^g' ghq-fzf

zle -N _gps
bindkey '^]' _gps

# bind key
zle -N _zi
bindkey '^z' _zi
