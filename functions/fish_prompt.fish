source (dirname (status -f))/shellder_segments.fish

function prompt_virtual_env -d "Display Python virtual environment"
	if test "$VIRTUAL_ENV"
		prompt_segment white black (basename $VIRTUAL_ENV)
	end
end

function prompt_user -d "Display current user if different from $default_user"
	set -l BG 444444
	set -l FG BCBCBC

	if [ "$theme_display_user" = "yes" ]
		if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
			set USER (whoami)
			get_hostname
			if [ $HOSTNAME_PROMPT ]
				set USER_PROMPT $USER@$HOSTNAME_PROMPT
			else
				set USER_PROMPT $USER
			end
			prompt_segment $BG $FG $USER_PROMPT
		end
	else
		get_hostname
		if [ $HOSTNAME_PROMPT ]
			prompt_segment $BG $FG $HOSTNAME_PROMPT
		end
	end
end

function get_hostname -d "Set current hostname to prompt variable $HOSTNAME_PROMPT if connected via SSH"
	set -g HOSTNAME_PROMPT ""
	if [ "$theme_hostname" = "always" -o \( "$theme_hostname" != "never" -a -n "$SSH_CLIENT" \) ]
		set -g HOSTNAME_PROMPT (hostname)
	end
end

function prompt_dir -d "Display the current directory"
	prompt_dirs_segment 212121 121212 FFFFFF E2E2E2 (dirs)
end

function prompt_git -d "Display the current git state"
	set -l ref
	if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
		set ref (command git symbolic-ref HEAD 2> /dev/null)
		if [ $status -gt 0 ]
			set -l branch (command git show-ref --head -s --abbrev |head -n1 2> /dev/null)
			set ref "➦ $branch "
		end
		set branch_symbol \uE0A0
		set -l branch (echo $ref | sed  "s-refs/heads/-$branch_symbol -")

		set -l BG PROMPT
		set -l dirty (command git status --porcelain --ignore-submodules=dirty 2> /dev/null)
		if [ "$dirty" = "" ]
			set BG green
			set PROMPT "$branch"
		else
			set BG yellow
			set dirty ''

			# Check if there's any commit in the repo
			set -l empty 0
			git rev-parse --quiet --verify HEAD > /dev/null 2>&1; or set empty 1

			set -l target
			if [ $empty = 1 ]
				# The repo is empty
				set target '4b825dc642cb6eb9a060e54bf8d69288fbee4904'
			else
				# The repo is not emtpy
				set target 'HEAD'

				# Check for unstaged change only when the repo is not empty
				set -l unstaged 0
				git diff --no-ext-diff --ignore-submodules=dirty --quiet --exit-code; or set unstaged 1
				if [ $unstaged = 1 ]; set dirty $dirty'●'; end
			end

			# Check for staged change
			set -l staged 0
			git diff-index --cached --quiet --exit-code --ignore-submodules=dirty $target; or set staged 1
			if [ $staged = 1 ]; set dirty $dirty'✚'; end

			# Check for dirty
			if [ "$dirty" = "" ]
				set PROMPT "$branch"
			else
				set PROMPT "$branch $dirty"
			end
		end
		prompt_segment $BG black $PROMPT
	end
end

function prompt_status -d "The symbols for a non zero exit status, root and background jobs"
		if [ $RETVAL -ne 0 ]
			prompt_segment black red "✘"
		end

		# if superuser (uid == 0)
		set -l uid (id -u $USER)
		if [ $uid -eq 0 ]
			prompt_segment black yellow "⚡"
		end

		# Jobs display
		if [ (jobs -l | wc -l) -gt 0 ]
			prompt_segment black cyan "⚙"
		end
end

# Set the prompt
function fish_prompt
	set -g RETVAL $status
	prompt_status
	prompt_virtual_env
	prompt_user
	prompt_dir
	command -v git &>/dev/null; and prompt_git
	prompt_finish
end
