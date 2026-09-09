function fzf_z --description 'Move with FZF + zoxide'
    set -l options i/insert
    argparse $options -- $argv

    # zoxide query --interactive は使わない。あれが起動する fzf には
    # FZF_DEFAULT_OPTS (unexported) が届かず、スコア列にも色を付けられないため、
    # ⌃] (fzf_ghq) と見た目が揃わない。代わりに --list --score を自前の fzf に
    # 流して、オプションを共有する。$argv は zoxide 側でのキーワード絞り込み。
    set -l opts (__frecency_fzf_opts)

    command zoxide query --list --score -- $argv 2>/dev/null \
        | ~/git/dotfiles/bin/frecency-fmt \
        | eval "fzf $FZF_DEFAULT_OPTS $opts" \
        | read -l select

    if test -n "$select"
        if set -q _flag_insert
            commandline -i "$select"
        else
            cd "$select"
        end
    end
    commandline -f repaint
end
