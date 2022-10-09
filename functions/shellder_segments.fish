set -g current_bg NONE
set -g segment_separator \uE0B0

function prompt_segment -d "Function to draw a segment"
	set -l bg
	set -l fg
	set bg $argv[1]
	set fg $argv[2]

	if [ "$current_bg" != 'NONE' -a "$argv[1]" != "$current_bg" ]
		set_color -b $bg
		set_color $current_bg
		echo -n " "
		set_color -b $bg
		set_color $fg
	else
		set_color -b $bg
		set_color $fg
		echo -n " "
	end
	set current_bg $argv[1]
	if [ -n "$argv[3]" ]
		echo -n -s $argv[3] " "
	end
end

function prompt_dirs_segment -d "Function to draw a path with alternating background colors"
	set -l bg1
	set -l bg2
	set -l fg1
	set -l fg2
	set bg1 $argv[1]
	set bg2 $argv[2]
	set fg1 $argv[3]
	set fg2 $argv[4]
	
	if [ "$current_bg" != 'NONE' -a "$argv[1]" != "$current_bg" ]
		set_color -b $bg1
		set_color $current_bg
		echo -n " "
		set_color -b $bg1
		set_color $fg1
	else
		set_color -b $bg1
		set_color $fg1
		echo -n " "
	end
	if [ -n "$argv[5]" ]
		set -l files
		if [ "$argv[5]" = "/" ]
			set files "/"
		else
			set files (string split "/" $argv[5])
		end
		for i in (seq (count $files))
			if [ (math $i % 2) -eq 0 ]
				set_color -b $bg2
				set_color $fg2
			else
				set_color -b $bg1
				set_color $fg1
			end
			echo -n $files[$i]
			if [ $i -eq (count $files) ]
				if [ (math $i % 2) -eq 0 ]
					#set_color -b $bg1
					set current_bg $bg2
				else
					#set_color -b $bg2
					set current_bg $bg1
				end
				break
			end
			echo -n "/"
		end
		echo -n " "
	end
end

function prompt_finish -d "Close open segments"
	if [ -n $current_bg ]
		set_color -b normal
		set_color $current_bg
		echo -n "$segment_separator "
	end
	set_color normal
	set -g current_bg NONE
end