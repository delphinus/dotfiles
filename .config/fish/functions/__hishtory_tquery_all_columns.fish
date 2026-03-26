function __hishtory_tquery_all_columns
    set -l tmp (mktemp -t fish.XXXXXX)
    set -x init_query (commandline -b)
    hishtory config-set displayed-columns Command Timestamp Runtime "Exit Code" Hostname CWD
    HISHTORY_TERM_INTEGRATION=1 HISHTORY_SHELL_NAME=fish hishtory tquery $init_query >$tmp
    set -l res $status
    hishtory config-set displayed-columns Command Timestamp Hostname
    commandline -f repaint
    if [ -s $tmp ]
        commandline -r -- (cat $tmp)
    end
    rm -f $tmp
end
