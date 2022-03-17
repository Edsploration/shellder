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

function prompt_finish -d "Close open segments"
	if [ -n $current_bg ]
		set_color -b normal
		set_color $current_bg
		echo -n "$segment_separator "
	end
	set_color normal
	set -g current_bg NONE
end