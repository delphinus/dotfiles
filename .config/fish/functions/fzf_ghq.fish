function fzf_ghq --description 'Move with FZF + ghq'
    ~/git/dotfiles/bin/faster-ghq-list \
        | eval "fzf $FZF_DEFAULT_OPTS" \
        | read -l select

    if test -n "$select"
        if set -q _flag_insert
            commandline -i "$select"
        else
            cd "$select"
            emit fish_prompt
        end
    end
    commandline -f repaint
end
