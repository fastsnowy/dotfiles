if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons --git"
  alias lt='eza -T -L 3 -a -I "node_modules|.git|.cache|.venv" --icons'
  alias ltl='eza -T -L 3 -a -I "node_modules|.git|.cache|.venv" -l --icons'
fi  

if command -v code-insiders >/dev/null 2>&1; then
  alias code="code-insiders"
fi

# git alias
alias gc="git clone"
