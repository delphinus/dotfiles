let g:rooter_use_lcd = 1
let g:rooter_silent_chdir = 1
if dein#tap('vim-rooter')
  augroup rooter
    autocmd!
    autocmd BufEnter * :Rooter
  augroup END
endif
