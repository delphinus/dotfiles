function _fzf_migemo_reload --description "Filter fd output using cmigemo for migemo-enhanced file search"
    set -l query $argv[1]
    set -l fd_cmd $argv[2..]

    if test -z "$query"
        command $fd_cmd --color=always 2>/dev/null
        return
    end

    # Find migemo dict
    set -l migemo_dict
    for dict in /opt/homebrew/share/migemo/utf-8/migemo-dict /usr/local/share/migemo/utf-8/migemo-dict
        if test -f "$dict"
            set migemo_dict $dict
            break
        end
    end

    if test -z "$migemo_dict"
        command $fd_cmd --color=always 2>/dev/null
        return
    end

    # Split query by spaces and convert each word to a migemo pattern,
    # then join with .* to match all words in order
    set -l words (string split ' ' -- "$query")
    set -l patterns
    for word in $words
        if test -z "$word"
            continue
        end
        set -l p (command cmigemo -w "$word" -d "$migemo_dict" 2>/dev/null)
        if test -n "$p"
            set --append patterns "$p"
        end
    end

    if test (count $patterns) -eq 0
        command $fd_cmd --color=always 2>/dev/null
        return
    end

    set -lx MIGEMO_PATTERN (string join '.*' -- $patterns)

    # Use perl to match against ANSI-stripped text but output original colored line
    command $fd_cmd --color=always 2>/dev/null | command perl -ne '
        $orig = $_;
        s/\e\[[0-9;]*m//g;
        print $orig if /$ENV{MIGEMO_PATTERN}/i;
    '
end
