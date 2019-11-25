# MIT License

# Copyright (c) 2016 Francisco Lourenço & Daniel Wehner

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -g __done_version 1.10.0

function __done_get_focused_window_id
	if type -q lsappinfo
		lsappinfo info -only bundleID (lsappinfo front) | cut -d '"' -f4
	else if test -n "$SWAYSOCK"
	and type -q jq
		swaymsg --type get_tree | jq '.. | objects | select(.focused == true) | .id'
	else if type -q xprop
	and test -n "$DISPLAY"
		xprop -root 32x '\t$0' _NET_ACTIVE_WINDOW | cut -f 2
	end
end

function __done_is_tmux_window_active
	set -q fish_pid; or set -l fish_pid %self

	not tmux list-panes -a -F "#{session_attached} #{window_active} #{pane_pid}" | string match -q "1 0 $fish_pid"
end

function __done_is_process_window_focused
	# Return false if the window is not focused
	if test $__done_initial_window_id != (__done_get_focused_window_id)
		return 1
	end
	# If inside a tmux session, check if the tmux window is focused
	if type -q tmux
	and test -n "$TMUX"
		__done_is_tmux_window_active
		return $status
	end

	return 0
end


# verify that the system has graphical capabilites before initializing
if test -z "$SSH_CLIENT"  # not over ssh
and count (__done_get_focused_window_id) > /dev/null  # is able to get window id

	set -g __done_initial_window_id ''
	set -q __done_min_cmd_duration; or set -g __done_min_cmd_duration 5000
	set -q __done_exclude; or set -g __done_exclude 'git (?!push|pull)'
	set -q __done_notify_sound; or set -g __done_notify_sound 0

	function __done_started --on-event fish_preexec
		set __done_initial_window_id (__done_get_focused_window_id)
	end

	function __done_ended --on-event fish_prompt
		set -l exit_status $status

		# backwards compatibilty for fish < v3.0
		set -q cmd_duration; or set -l cmd_duration $CMD_DURATION

		if test $cmd_duration
		and test $cmd_duration -gt $__done_min_cmd_duration # longer than notify_duration
		and not __done_is_process_window_focused  # process pane or window not focused
		and not string match -qr $__done_exclude $history[1] # don't notify on git commands which might wait external editor

			# Store duration of last command
			set -l humanized_duration (echo "$cmd_duration" | humanize_duration)

			set -l title "Done in $humanized_duration"
			set -l wd (pwd | sed "s,^$HOME,~,")
			set -l message "$wd/ $history[1]"
			set -l sender $__done_initial_window_id

			if test $exit_status -ne 0
				set title "Failed ($exit_status) after $humanized_duration"
			end

			if set -q __done_notification_command
				eval $__done_notification_command
				if test "$__done_notify_sound" -eq 1
					echo -e "\a" # bell sound
				end
			else if type -q terminal-notifier  # https://github.com/julienXX/terminal-notifier
				if test "$__done_notify_sound" -eq 1
					terminal-notifier -message "$message" -title "$title" -sender "$__done_initial_window_id" -sound default
				else
					terminal-notifier -message "$message" -title "$title" -sender "$__done_initial_window_id"
				end

			else if type -q osascript  # AppleScript
				osascript -e "display notification \"$message\" with title \"$title\""
				if test "$__done_notify_sound" -eq 1
					echo -e "\a" # bell sound
				end

			else if type -q notify-send # Linux notify-send
				set -l urgency
				if test $exit_status -ne 0
					set urgency "--urgency=critical"
				end
				notify-send $urgency --icon=terminal --app-name=fish "$title" "$message"
				if test "$__done_notify_sound" -eq 1
					echo -e "\a" # bell sound
				end

			else if type -q notify-desktop # Linux notify-desktop
				set -l urgency
				if test $exit_status -ne 0
					set urgency "--urgency=critical"
				end
				notify-desktop $urgency --icon=terminal --app-name=fish "$title" "$message"
				if test "$__done_notify_sound" -eq 1
					echo -e "\a" # bell sound
				end

			else  # anything else
				echo -e "\a" # bell sound
			end

		end
	end
end

function __done_uninstall -e done_uninstall
  # Erase all __done_* functions
  functions -e __done_ended
  functions -e __done_started
  functions -e __done_get_focused_window_id
  functions -e __done_is_tmux_window_active
  functions -e __done_is_process_window_focused

  # Erase __done variables
  set -e __done_version
end

