# fzf integration options (loaded before `source <(fzf --zsh)` in defer/inline.zsh)

export FZF_DEFAULT_OPTS="
  --border
  --ansi
  --bind 'ctrl-/:change-preview-window(right:70%|hidden|)'
"

export FZF_CTRL_T_OPTS="
  --preview-window 'right:60%'
  --preview '
    if [ -d {} ]; then
      eza -T --level=2 --icons=always --color=always {}
    else
      bat -n --color=always --line-range :500 {} 2>/dev/null || cat {}
    fi
  '
"

export FZF_ALT_C_OPTS="
  --preview-window 'right:60%'
  --preview 'eza -T --level=2 --icons=always --color=always {}'
"
