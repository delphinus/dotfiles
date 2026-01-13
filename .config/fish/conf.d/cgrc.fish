
set -l grc_plugin_execs configure env gcc ifconfig lsof mount netstat \
    sysctl uptime vmstat whois

if command -s cgrc > /dev/null
    for executable in $grc_plugin_execs
        function $executable --inherit-variable executable --wraps=$executable
            set -l options "grc_wrap_options_$cmd"
            command "$executable" $argv | cgrc $$options "$executable"
        end
    end
else
    echo "Looks like 'cgrc' is not installed on this system."
end
