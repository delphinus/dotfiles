function fzf_ghq --description 'Move with FZF + ghq'
    set -l options i/insert
    argparse $options -- $argv

    # faster-ghq-list --score は "  848.0<TAB>/path" を frecency 降順で出す。
    # fzf 側のオプションは fzf_z (⌃T) と共有している。
    # FZF_DEFAULT_OPTS を先に置いて $opts で上書きする (--height / --border /
    # --info は ⌃T 側の値を採る)。--prompt はどちらにも無いので生き残る。
    set -l opts (__frecency_fzf_opts)

    ~/git/dotfiles/bin/faster-ghq-list --score \
        | eval "fzf $FZF_DEFAULT_OPTS $opts" \
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
