let g:rooter_use_lcd = 1
let g:rooter_silent_chdir = 1
augroup rooter
  autocmd!
  autocmd BufEnter * :Rooter
augroup END
