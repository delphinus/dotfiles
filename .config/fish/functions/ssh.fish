function ssh -d 'Use the ssh kitten inside kitty so that xterm-kitty terminfo reaches the remote'
  # kitty は xterm-kitty の terminfo を app バンドル (kitty.app/Contents/Resources/
  # kitty/terminfo) に持ち、$TERMINFO でシェルに教えている。ssh では TERM だけが
  # 相手に渡り TERMINFO は渡らないので、terminfo を持たないホストに入ると
  # clear / tput が "'xterm-kitty': unknown terminal type." で落ちる。
  #
  # kitten ssh は接続時に terminfo を相手の ~/.terminfo へ送り込むので、ホスト側の
  # 事前準備が要らない。ただし以下が前提なので、外れたら素の ssh に落とす:
  #
  #   - 端末が本物の kitty (bootstrap が DCS で kitty に問い合わせて応答を待つ)
  #   - stdin が端末 ("The SSH kitten is meant for interactive use only")
  #
  # tmux の中は TERM が tmux-256color になり、この問題自体が起きないので対象外。
  #
  # 普通の sh を持たないホストにも kitten ssh では入れない。bootstrap は base64 の
  # スクリプトを相手のシェルに流し込んで実行させるので、制限シェルの踏み台では、
  # それがそのまま画面に出るだけになる。こうしたホストは $SSH_NO_KITTEN_HOSTS に
  # 空白区切りの glob で並べる (例: '*.example.local bastion.example.com')。
  # 社内のホスト名なのでリポジトリには書かず、secrets.yml の secret_env から渡す。
  # 判定は ssh -G が解決した hostname で行うので、-A や -o などのオプションを
  # 付けても、~/.ssh/config の別名で呼んでも判定できる。
  set -l no_kitten_hosts (string split -n ' ' -- "$SSH_NO_KITTEN_HOSTS")

  if type -q kitten; and test "$TERM" = xterm-kitty; and set -q KITTY_WINDOW_ID; and isatty stdin
    set -l host (command ssh -G $argv 2>/dev/null | string replace -rf '^hostname ' '')
    for pattern in $no_kitten_hosts
      if test -n "$host"; and string match -q -- $pattern $host
        # 素の ssh だと TERM=xterm-kitty がそのまま渡り、上に書いた
        # unknown terminal type で困る。どこにでもある xterm-256color を名乗る。
        # -t で転送した TERM は、そこから先の多段の ssh にも引き継がれる。
        TERM=xterm-256color command ssh $argv
        return
      end
    end
    kitten ssh $argv
  else
    command ssh $argv
  end
end
