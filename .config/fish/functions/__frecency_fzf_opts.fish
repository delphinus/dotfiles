function __frecency_fzf_opts --description 'Shared fzf options for the frecency-ordered pickers (⌃] and ⌃T)'
    # "<グレーのスコア><TAB><path>" の行 (bin/frecency-fmt の出力) を frecency 降順
    # のまま見せるためのオプション一式。fzf_ghq (⌃]) と fzf_z (⌃T) で共有する。
    #
    #   --tiebreak=index
    #                  マッチスコアが同点なら入力順 (= frecency 降順) を採る。
    #                  クエリが空なら全部同点なので frecency 降順そのものになる。
    #                  ここを --no-sort にすると fzf がマッチスコアを一切見なく
    #                  なり、「ゆるく fuzzy マッチしただけの高スコア項目」が
    #                  「部分一致している低スコア項目」より必ず上に来てしまう
    #                  (実例: "scr" で md-render.nvim (256) が claude-scratch
    #                  (64) を押し退ける。.local/share の s/c/r を拾っている)
    #   --nth=2..      検索対象をパスだけに限る (スコアの数字にマッチさせない)
    #   --accept-nth=2 選択したらパスだけを返す
    #   --ansi         スコアのグレー表示を解釈させる
    set -l opts --tiebreak=index --ansi --delimiter='\t' --nth=2.. --accept-nth=2

    # 以下は zoxide 0.10.0 が query --interactive で fzf に渡している値をそのまま
    # 持ってきたもの。⌃T の見た目が元々こうだったので、それに合わせている。
    # 採らなかったのは --exact (fuzzy matching を残すため)、--read0 (--list は
    # 改行区切りなので不要)、--nth=2 (上の --nth=2.. で置き換え)。
    set -a opts --layout=reverse --height=45% --border=sharp --info=inline
    set -a opts --cycle --keep-right --tabstop=1 --exit-0
    set -a opts --bind=ctrl-z:ignore,btab:up,tab:down
    # zoxide は fzf のプロセスに CLICOLOR=1 と CLICOLOR_FORCE=1 を撒いていて、
    # プレビューの ls がそれを継いで色付きになっていた。ここでは fzf の環境を
    # 汚さずに済むよう、プレビューのコマンド側に env で渡す。BSD ls は
    # CLICOLOR (= -G) で色付けを有効化し、CLICOLOR_FORCE で端末以外への出力でも
    # 色を出す。両方要る。
    set -a opts "--preview='env CLICOLOR=1 CLICOLOR_FORCE=1 ls -Cp {2..}'"
    set -a opts --preview-window=down,30%,sharp

    printf '%s\n' $opts
end
