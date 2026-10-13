# Register user-scope skills with chezmoi.
function skills-sync() {
    local skill_paths
    skill_paths=$(command gh skill list --scope user --json path --jq '.[].path') || return

    local -a targets
    local skill_path
    for skill_path in "${(@f)skill_paths}"; do
        [[ -z "$skill_path" ]] && continue
        targets+=("$skill_path")
    done
    if [[ -f "$HOME/.agents/.skill-lock.json" ]]; then
        targets+=("$HOME/.agents/.skill-lock.json")
    fi
    (( ${#targets} )) || return 0
    command chezmoi add -- "${targets[@]}"
}

# Preserve the usual CLI syntax and only sync after successful changes.
function gh() {
    local sync_skills=0 arg
    if [[ "$1" == (skill|skills) && "$2" == (install|add|update) ]]; then
        sync_skills=1
    fi
    for arg in "$@"; do
        [[ "$arg" == (--help|-h|--dry-run) ]] && sync_skills=0
    done
    command gh "$@" || return
    (( sync_skills )) || return 0
    skills-sync
}

function npx() {
    local sync_skills=0 arg
    if [[ "$1" == (skills|skills@*) && "$2" == (add|a|update) ]]; then
        sync_skills=1
    fi
    for arg in "$@"; do
        [[ "$arg" == (--help|-h|--list|-l) ]] && sync_skills=0
    done
    command npx "$@" || return
    (( sync_skills )) || return 0
    skills-sync
}
