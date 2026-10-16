if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi
if command -v sheldon >/dev/null 2>&1; then
    eval "$(sheldon source)"
fi
