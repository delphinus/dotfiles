scriptencoding utf-8

" for Vim
if exists('&termwinkey')
  set termwinkey=<A-w>
endif

augroup terminal-autocmd
  autocmd!
  if has('nvim')
    " set option for terminals
    autocmd TermOpen term://* setlocal scrolloff=0 nonumber norelativenumber | startinsert
    " change to insert mode if in terminal
    autocmd WinEnter term://* startinsert
    " invoke focus events in/out terminals
    autocmd WinEnter term://* doautocmd <nomodeline> FocusGained %
    autocmd WinLeave term://* doautocmd <nomodeline> FocusLost % 
  else
    autocmd TerminalOpen * setlocal scrolloff=0 nonumber norelativenumber nolist colorcolumn=0 | normal i
    autocmd WinEnter * if &buftype ==# 'terminal' | normal i | endif
    autocmd WinEnter * if &buftype ==# 'terminal' | doautocmd <nomodeline> FocusGained % | endif
    autocmd WinLeave * if &buftype ==# 'terminal' | doautocmd <nomodeline> FocusLost % | endif
  endif
augroup END

if !has('nvim')
  " s:map_alt_keys is for Vim. It defines special characters to behave as
  " <A-*> key bindings. Neovim does NOT need this. (See :h vim-diff)
  function! s:map_alt_keys() abort
    let code = 91  " '['
    while code <= 122  " 'z'
      let c = nr2char(code)
      let cc = toupper(c)
      execute 'set <A-' . c . '>=' . c
      execute 'set <A-' . cc . '>=' . cc
      let code = code + 1
    endwhile
  endfunction

  call s:map_alt_keys()
endif

" mapping for normal <A-> modifier
tmap <A-j> <C-\><C-n><C-j>
tmap <A-k> <C-\><C-n><C-k>
tmap <A-o> <C-\><C-n><C-w>oi
tmap <A-q> <C-\><C-n><C-q>
tmap <A-s> <C-\><C-n><C-s>
tmap <A-CR> <C-\><C-n><A-CR>
tmap <A-;> <C-\><C-n>:
tmap <A-t> <C-\><C-n>gt
tnoremap <expr> <A-r> '<C-\><C-n>"'.nr2char(getchar()).'pi'
nmap <A-j> <C-j>
nmap <A-k> <C-k>
nmap <A-o> <C-w>o
nmap <A-q> <C-q>
nmap <A-s> <C-s>
nmap <A-;> :
nmap <A-t> gt
