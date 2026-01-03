git_status() {
	if git rev-parse --is-inside-work-tree &>/dev/null; then
		local g_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
    local g_status=$(git status --porcelain 2>/dev/null | wc -l)
    if [ "$status" -gt 0 ]; then
			echo " %F{green}$g_branch ⚡ $g_status%f"
    else
      echo " %F{green}$g_branch%f"
    fi
	fi
}

PROMPT='%F{blue}  %2~%f%F{gray}$(git_status) ∮%  ' #'%F{blue}  %2~%f%F{gray} ∮%  ' #'%B%(!.#.$)%b '

setopt prompt_subst
