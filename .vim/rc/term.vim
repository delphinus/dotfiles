scriptencoding utf-8

" for Vim
if exists('&termwinkey')
  set termwinkey=<A-w>
endif

" Deol setting
if !dein#tap('deol.nvim')
  " open terminal in new window (<C-N> should be mapped to <Plug>DWMNew)
  nmap <C-\><C-N> <C-N>:terminal ++close ++curwin<cr><A-w>:silent set nonumber norelativenumber nolist colorcolumn=0<cr>
endif

augroup terminal-autocmd
  autocmd!
  if has('nvim')
    " change to insert mode if in terminal
    autocmd WinEnter * if &buftype ==# 'terminal' | startinsert | endif
    " set option for terminals
    autocmd TermOpen * setlocal scrolloff=0
  else
    autocmd WinEnter * if &buftype ==# 'terminal' | normal i | endif
    autocmd TerminalOpen * setlocal scrolloff=0
  endif
  " invoke focus events in/out terminals
  autocmd WinEnter * if &buftype ==# 'terminal' | doautocmd <nomodeline> FocusGained % | endif
  autocmd WinLeave * if &buftype ==# 'terminal' | doautocmd <nomodeline> FocusLost % | endif
augroup END

function! s:close_quit_deol() abort
  if exists('t:deol')
    let win = bufwinnr(t:deol.bufnr)
    if win > -1
      execute win . 'q'
    endif
  endif
endfunction

" mapping for normal <A-> modifier
tmap <silent> <A-c> <C-\><C-n>:<C-u>call <SID>close_quit_deol()<CR>
tmap <A-j> <C-\><C-n><C-j>
tmap <A-k> <C-\><C-n><C-k>
tmap <A-o> <C-\><C-n><C-w>oi
tmap <A-q> <C-\><C-n><C-q>
tmap <A-s> <C-\><C-n><C-s>
tmap <A-CR> <C-\><C-n><A-CR>
tmap <A-;> <C-\><C-n>:
tmap <A-t> <C-\><C-n>gt
tnoremap <expr> <A-r> '<C-\><C-n>"'.nr2char(getchar()).'pi'
nmap <silent> <A-c> :<C-u>call <SID>close_quit_deol()<CR>
nmap <A-j> <C-j>
nmap <A-k> <C-k>
nmap <A-o> <C-w>o
nmap <A-q> <C-q>
nmap <A-s> <C-s>
nmap <A-;> :
nmap <A-t> gt

" mapping for iTerm2 setting `Normal`
tmap <silent> ç     <C-\><C-n>:<C-u>call <SID>close_quit_deol()<CR>
tmap ∆     <C-\><C-n><C-j>
tmap ˚     <C-\><C-n><C-k>
tmap ø     <C-\><C-n><C-w>oi
tmap œ     <C-\><C-n><C-q>
tmap ß     <C-\><C-n><C-s>
tmap       <C-\><C-n><A-CR>
tmap …     <C-\><C-n>:
tmap †     <C-\><C-n>gt
tnoremap <expr> ® '<C-\><C-n>"'.nr2char(getchar()).'pi'
nmap <silent> ç     :<C-u>call <SID>close_quit_deol()<CR>
nmap ∆     <C-j>
nmap ˚     <C-k>
nmap ø     <C-w>o
nmap œ     <C-q>
nmap ß     <C-s>
nmap       <A-CR>
nmap …     :
nmap †     gt

" mapping for iTerm2 setting `Meta`
tmap <silent> ã     <C-\><C-n>:<C-u>call <SID>close_quit_deol()<CR>
tmap ê     <C-\><C-n><C-j>
tmap ë     <C-\><C-n><C-k>
tmap ï     <C-\><C-n><C-w>oi
tmap ñ     <C-\><C-n><C-q>
tmap ó     <C-\><C-n><C-s>
tmap       <C-\><C-n><A-CR>
tmap »     <C-\><C-n>:
tmap ô     <C-\><C-n>gt
tnoremap <expr> ò '<C-\><C-n>"'.nr2char(getchar()).'pi'
nmap <silent> ã     :<C-u>call <SID>close_quit_deol()<CR>
nmap ê     <C-j>
nmap ë     <C-k>
nmap ï     <C-w>o
nmap ñ     <C-q>
nmap ó     <C-s>
nmap       <A-CR>
nmap »     :
nmap ô     gt
