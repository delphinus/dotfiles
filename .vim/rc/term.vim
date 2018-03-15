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

if !dein#tap('deol.nvim') && !has('nvim')
  set termkey=<A-w>
  " open terminal in new window (<C-N> should be mapped to <Plug>DWMNew)
  nmap <C-\><C-N> <C-N>:terminal ++close ++curwin<cr><A-w>:silent set nonumber norelativenumber nolist colorcolumn=0<cr>
endif
