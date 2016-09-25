if exists('g:loaded_delphinus_fssh')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

nnoremap <Plug>DelphinusFsshCopy :call delphinus#fssh#copy()<CR>

let g:loaded_delphinus_fssh = 1

let &cpo = s:save_cpo
unlet s:save_cpo
