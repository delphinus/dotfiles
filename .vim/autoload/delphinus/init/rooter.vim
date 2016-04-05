function! delphinus#init#rooter#hook_add() abort
  let g:rooter_use_lcd = 1
  let g:rooter_silent_chdir = 1
  autocmd BufEnter * Rooter
endfunction
