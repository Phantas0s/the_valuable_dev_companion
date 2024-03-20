# Version 2

function fgf() {
		local -r prompt_add="Add > "
		local -r prompt_reset="Reset > "

		local -r git_root_dir=$(git rev-parse --show-toplevel)
		local -r git_unstaged_files="git ls-files --modified --deleted --other --exclude-standard --deduplicate $git_root_dir"
		local git_staged_files
		read -r -d '' git_staged_files <<-'EOF'
			git status --short | grep "^[A-Z]" | awk "{print \$NF}"
		EOF

		local -r git_reset="git reset -- {+}"
		local -r enter_cmd="($git_unstaged_files | grep {} && git add {+}) || $git_reset"

		local -r mode_reset="change-prompt($prompt_reset)+reload($git_staged_files)+unbind(alt-p)+rebind(alt-c)"
		local -r mode_add="change-prompt($prompt_add)+reload($git_unstaged_files)+rebind(alt-p)+unbind(alt-c)"

		local -r preview_status_label="[ Status ]"
		local -r preview_status="git status --short"

		eval "$git_unstaged_files" | fzf \
		--multi \
		--reverse \
		--no-sort \
		--prompt="Add > " \
		--preview-label="$preview_status_label" \
		--preview="$preview_status" \
		--bind='start:unbind(alt-c)' \
		--bind='f1:toggle-header' \
		--bind='f2:toggle-preview' \
		--bind="ctrl-t:change-preview-label($preview_status_label)" \
		--bind="ctrl-t:+change-preview($preview_status)" \
		--bind='ctrl-f:change-preview-label([ Diff ])' \
		--bind='ctrl-f:+change-preview(git diff --color=always {} | sed "1,4d")' \
		--bind='ctrl-b:change-preview-label([ Blame ])' \
		--bind='ctrl-b:+change-preview(git blame --color-by-age {})' \
		--bind="ctrl-s:transform:[[ \$FZF_PROMPT =~ '$prompt_add' ]] && echo '$mode_reset' || echo '$mode_add'" \
		--bind='ctrl-y:preview-up' \
		--bind='ctrl-e:preview-down' \
		--bind='ctrl-u:preview-half-page-up' \
		--bind='ctrl-d:preview-half-page-down' \
		--bind="enter:execute($enter_cmd)" \
		--bind="enter:+reload([[ \$FZF_PROMPT =~ '$prompt_add' ]] && $git_unstaged_files || $git_staged_files)" \
		--bind="enter:+refresh-preview" \
		--bind='alt-p:execute(git add --patch {+})' \
		--bind="alt-p:+reload($git_unstaged_files)" \
		--bind="alt-d:execute($git_reset && git checkout {+})" \
		--bind="alt-d:+reload($git_staged_files)" \
		--bind 'alt-c:execute(git commit)+abort' \
		--bind 'alt-a:execute(git commit --append)+abort' \
		--bind 'alt-e:execute(${EDITOR:-vim} {+})' \
		--header-first \
		--header "$(cat <<-EOF
		> CTRL-S to switch between Add and Reset mode
		> CTRL_T for status preview | CTRL-F for diff preview | CTRL-B for blame preview
		> ENTER to Add or reset files | TAB to select multiple files
		> ALT-E to open files in your editor
		> ALT-P to Add patch (Add mode only)
		> ALT-D to Reset and Checkout the file (Reset mode only)
		> ALT-C to commit | ALT-A to append to the last commit
		EOF
		)"
}

# TO ADD NEXT
# Impossbile to rotate through that

