scriptencoding utf-8

" iTerm2 上の場合
" インサートモードでカーソルの形状を変える
if exists('$TMUX')
  let &t_SI = "\ePtmux;\e\e]50;CursorShape=1\x7\e\\"
  let &t_SR = "\ePtmux;\e\e]50;CursorShape=2\x7\e\\"
  let &t_EI = "\ePtmux;\e\e]50;CursorShape=0\x7\e\\"
else
  let &t_SI = "\e]50;CursorShape=1\x7"
  let &t_SR = "\e]50;CursorShape=2\x7"
  let &t_EI = "\e]50;CursorShape=0\x7"
endif

if &term =~? '256color'
  " Disable Background Color Erase (BCE) so that color schemes
  " work properly when Vim is used inside tmux and GNU screen.
  " See also http://snk.tuxfamily.org/log/vim-256color-bce.html
  set t_ut=
endif
