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

if !has('nvim')
  set termkey=<A-w>
  if !dein#tap('deol.nvim')
    " open terminal in new window (<C-N> should be mapped to <Plug>DWMNew)
    nmap <C-\><C-N> <C-N>:terminal ++close ++curwin<cr><A-w>:silent set nonumber norelativenumber nolist colorcolumn=0<cr>
  endif
endif

" map for terminal + dwm.vim
augroup InsertIfTerminal
  autocmd!
  if has('nvim')
    autocmd WinEnter * if &buftype ==# 'terminal' | startinsert | endif
  else
    autocmd WinEnter * if &buftype ==# 'terminal' | normal i | endif
  endif
augroup END

tmap À     <C-\><C-n><C-@>
tmap <A-@> <C-\><C-n><C-@>
tmap ã     <C-\><C-n><C-c>
tmap <A-c> <C-\><C-n><C-c>
tmap ê     <C-\><C-n><C-j>
tmap <A-j> <C-\><C-n><C-j>
tmap ë     <C-\><C-n><C-k>
tmap <A-k> <C-\><C-n><C-k>
tmap ï     <C-\><C-n><C-w>oi
tmap <A-o> <C-\><C-n><C-w>oi
tmap ñ     <C-\><C-n><C-q>
tmap <A-q> <C-\><C-n><C-q>
tmap ó     <C-\><C-n><C-s>
tmap <A-s> <C-\><C-n><C-s>
tmap       <C-\><C-n><C-@>
tmap <A-Space> <C-\><C-n><C-@>
tmap »     <C-\><C-n>:
tmap <A-;> <C-\><C-n>:
tmap ô     <C-\><C-n>gt
tmap <A-t> <C-\><C-n>gt
tnoremap <expr> ò     '<C-\><C-n>"'.nr2char(getchar()).'pi'
tnoremap <expr> <A-r> '<C-\><C-n>"'.nr2char(getchar()).'pi'
nmap À     <C-@>
nmap <A-@> <C-@>
nmap ã     <C-c>
nmap <A-c> <C-c>
nmap ê     <C-j>
nmap <A-j> <C-j>
nmap ë     <C-k>
nmap <A-k> <C-k>
nmap ï     <C-w>o
nmap <A-o> <C-w>o
nmap ñ     <C-q>
nmap <A-q> <C-q>
nmap ó     <C-s>
nmap <A-s> <C-s>
nmap       <C-@>
nmap <A-Space> <C-@>
nmap »     :
nmap <A-;> :
nmap ô     gt
nmap <A-t> gt
