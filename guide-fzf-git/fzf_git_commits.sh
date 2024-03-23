#!/usr/bin/env bash

function fgc() {
	local -r git_log=$(cat <<-EOF
		git log --graph --color --format="%C(white)%h - %C(green)%cs - %C(blue)%s%C(red)%d"
	EOF
	)

	local -r git_log_all=$(cat <<-EOF
		git log --all --graph --color --format="%C(white)%h - %C(green)%cs - %C(blue)%s%C(red)%d"
	EOF
	)


	local get_hash
	read -r -d '' get_hash <<-'EOF'
		echo {} | grep -o "[a-f0-9]\{7\}" | sed -n "1p"
	EOF

	local -r git_show="[[ \$($get_hash) != '' ]] && git show --color \$($get_hash)"
	local -r git_show_subshell=$(cat <<-EOF
		[[ \$($get_hash) != '' ]] && sh -c "git show --color \$($get_hash) | less -R"
	EOF
	)

	local -r git_checkout="[[ \$($get_hash) != '' ]] && git checkout \$($get_hash)"
	local -r git_reset="[[ \$($get_hash) != '' ]] && git reset \$($get_hash)"
	local -r git_rebase_interactive="[[ \$($get_hash) != '' ]] && git rebase --interactive \$($get_hash)"
	local -r git_cherry_pick="[[ \$($get_hash) != '' ]] && git cherry-pick \$($get_hash)"

	local -r header=$(cat <<-EOF
		> ENTER to display the diff with less
	EOF
	)

	local -r header_branch=$(cat <<-EOF
		$header
		> CTRL-S to switch to All Commits mode
		> ALT-C to checkout the commit | ALT-R to reset to the commit
		> ALT-I to rebase interactively until the commit
	EOF
	)

	local -r header_all=$(cat <<-EOF
		$header
		> CTRL-S to switch to Branch Commits mode
		> ALT-P to cherry pick
	EOF
	)

	local -r branch_prompt='Branch > '
	local -r all_prompt='All > '

	local -r mode_all="change-prompt($all_prompt)+reload($git_log_all)+change-header($header_all)+unbind(alt-c)+unbind(alt-r)+unbind(alt-i)+rebind(alt-p)"
	local -r mode_branch="change-prompt($branch_prompt)+reload($git_log)+change-header($header_branch)+rebind(alt-c)+rebind(alt-r)+rebind(alt-i)+unbind(alt-p)"

	eval "$git_log" | fzf \
		--ansi \
		--reverse \
		--no-sort \
		--prompt="$branch_prompt" \
		--header-first \
		--header="$header_branch" \
		--preview="$git_show" \
		--bind='start:unbind(alt-p)' \
		--bind="ctrl-s:transform:[[ \$FZF_PROMPT =~ '$branch_prompt' ]] && echo '$mode_all' || echo '$mode_branch'" \
		--bind="enter:execute($git_show_subshell)" \
		--bind="alt-c:execute($git_checkout)+abort" \
		--bind="alt-r:execute($git_reset)+abort" \
		--bind="alt-i:execute($git_rebase_interactive)+abort" \
		--bind="alt-p:execute($git_cherry_pick)+abort" \
		--bind='f1:toggle-header' \
		--bind='f2:toggle-preview' \
		--bind='ctrl-y:preview-up' \
		--bind='ctrl-e:preview-down' \
		--bind='ctrl-u:preview-half-page-up' \
		--bind='ctrl-d:preview-half-page-down'
}

