#!/usr/bin/env bash

# Version 1

function fug() {
		local -r prompt_add="Add > "
		local -r prompt_reset="Reset > "

		local -r git_root_dir=$(git rev-parse --show-toplevel)
		local -r git_unstaged_files="git ls-files --modified --deleted --other --exclude-standard --deduplicate $git_root_dir"
		local git_staged_files
		read -r -d '' git_staged_files <<-'EOF'
			git status --short | grep "^[A-Z]" | awk "{print \$NF}"
		EOF

		local -r enter_cmd="($git_unstaged_files | grep {} && git add {+}) || git reset -- {+}"

		local -r mode_reset="change-prompt($prompt_reset)+reload($git_staged_files)"
		local -r mode_add="change-prompt($prompt_add)+reload($git_unstaged_files)"

		eval "$git_unstaged_files" | fzf \
		--multi \
		--reverse \
		--no-sort \
		--prompt="Add > " \
		--preview="git status --short" \
		--bind='f1:toggle-header' \
		--bind='f2:toggle-preview' \
		--bind="ctrl-s:transform:[[ \$FZF_PROMPT =~ '$prompt_add' ]] && echo '$mode_reset' || echo '$mode_add'" \
		--bind="enter:execute($enter_cmd)" \
		--bind="enter:+reload([[ \$FZF_PROMPT =~ '$prompt_add' ]] && $git_unstaged_files || $git_staged_files)" \
		--bind="enter:+refresh-preview" \
		--header-first \
		--header "$(cat <<-EOF
		> CTRL-S to switch between Add and Reset mode
		> ENTER to Reset or Add files | TAB to select multiple files
		EOF
		)"
}

