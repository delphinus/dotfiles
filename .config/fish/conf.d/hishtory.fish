# ~/.hishtory/config.fish から、履歴を記録するフックだけを写したもの。
# config.fish を source しない理由は config.fish の hishtory の節に書いた。
# hishtory を更新してフックが変わったら、ここも合わせる。
status is-interactive; or exit 0
type -q hishtory; or exit 0

function _hishtory_post_exec --on-event fish_preexec
    # Runs after <ENTER>, but before the command is executed
    set --global _hishtory_command $argv
    set --global _hishtory_start_time (hishtory getTimestamp)
    hishtory presaveHistoryEntry fish "$_hishtory_command" $_hishtory_start_time 2>&1 >/dev/null &
    disown
end

set --global _hishtory_first_prompt 1

function __hishtory_on_prompt --on-event fish_prompt
    # Runs after the command is executed in order to render the prompt
    # $? contains the exit code
    set _hishtory_exit_code $status
    if [ -n "$_hishtory_first_prompt" ]
        set --global -e _hishtory_first_prompt
    else if [ -n "$_hishtory_command" ]
        hishtory saveHistoryEntry fish $_hishtory_exit_code "$_hishtory_command" $_hishtory_start_time 2>&1 >/dev/null &
        disown
        hishtory updateLocalDbFromRemote 2>&1 >/dev/null &
        disown
        # Unset _hishtory_command so we don't double-save entries when fish_prompt is invoked but fish_postexec isn't
        set --global -e _hishtory_command
    end
end

function __hishtory_on_control_r
    set -l tmp (mktemp -t fish.XXXXXX)
    set -x init_query (commandline -b)
    HISHTORY_TERM_INTEGRATION=1 HISHTORY_SHELL_NAME=fish hishtory tquery $init_query >$tmp
    commandline -f repaint
    if [ -s $tmp ]
        commandline -r -- (cat $tmp)
    end
    rm -f $tmp
end
