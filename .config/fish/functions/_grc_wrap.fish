function _grc_wrap -a cmd
    if command -s grc > /dev/null
        if set -q grc_wrap_commands
            if not builtin contains -- "$cmd" $grc_wrap_commands
                return
            end
        end

        function "$cmd" -V cmd -w "$cmd"
            set -l options "grc_wrap_options_$cmd"
            command grc -es --colour=auto "$cmd" $$options $argv
        end
    end
end
