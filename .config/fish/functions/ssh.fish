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
  if type -q kitten; and test "$TERM" = xterm-kitty; and set -q KITTY_WINDOW_ID; and isatty stdin
    kitten ssh $argv
  else
    command ssh $argv
  end
end
