let g:rooter_use_lcd = 1
let g:rooter_manual_only = 1
augroup rooter
	autocmd!
	autocmd BufEnter * :Rooter
augroup END
