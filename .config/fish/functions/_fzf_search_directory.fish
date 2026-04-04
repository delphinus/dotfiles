function _fzf_search_directory --description "Search the current directory. Replace the current token with the selected file paths."
    # Directly use fd binary to avoid output buffering delay caused by a fd alias, if any.
    # Debian-based distros install fd as fdfind and the fd package is something else, so
    # check for fdfind first. Fall back to "fd" for a clear error message.
    set -f fd_cmd (command -v fdfind || command -v fd  || echo "fd")
    set -f --append fd_cmd $fzf_fd_opts

    set -f fzf_arguments --multi --ansi $fzf_directory_opts
    set -f token (commandline --current-token)
    # expand any variables or leading tilde (~) in the token
    set -f expanded_token (eval echo -- $token)
    # unescape token because it's already quoted so backslashes will mess up the path
    set -f unescaped_exp_token (string unescape -- $expanded_token)

    # Check if cmigemo is available for migemo-enhanced search
    set -f use_migemo false
    if command -q cmigemo
        for dict in /opt/homebrew/share/migemo/utf-8/migemo-dict /usr/local/share/migemo/utf-8/migemo-dict
            if test -f "$dict"
                set use_migemo true
                break
            end
        end
    end

    # If the current token is a directory and has a trailing slash,
    # then use it as fd's base directory.
    if string match --quiet -- "*/" $unescaped_exp_token && test -d "$unescaped_exp_token"
        set --append fd_cmd --base-directory=$unescaped_exp_token
        # use the directory name as fzf's prompt to indicate the search is limited to that directory
        set --prepend fzf_arguments --prompt="Directory $unescaped_exp_token> " --preview="_fzf_preview_file $expanded_token{}"
        if $use_migemo
            set -f reload_cmd (string join ' ' -- $fd_cmd)
            set --prepend fzf_arguments --disabled \
                --bind "change:reload:_fzf_migemo_reload {q} $reload_cmd"
        end
        set -f file_paths_selected $unescaped_exp_token($fd_cmd --color=always 2>/dev/null | _fzf_wrapper $fzf_arguments)
    else
        set --prepend fzf_arguments --prompt="Directory> " --query="$unescaped_exp_token" --preview='_fzf_preview_file {}'
        if $use_migemo
            set -f reload_cmd (string join ' ' -- $fd_cmd)
            set --prepend fzf_arguments --disabled \
                --bind "change:reload:_fzf_migemo_reload {q} $reload_cmd"
        end
        set -f file_paths_selected ($fd_cmd --color=always 2>/dev/null | _fzf_wrapper $fzf_arguments)
    end


    if test $status -eq 0
        commandline --current-token --replace -- (string escape -- $file_paths_selected | string join ' ')
    end

    commandline --function repaint
end
