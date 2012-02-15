"-----------------------------------------------------------------------------
" vim-ref
let g:ref_open=':vsp'
let g:ref_alc_start_linenumber=42
noremap <Leader>ra :Unite ref/alc<CR>
noremap <Leader>rc :Unite ref/clojure<CR>
noremap <Leader>re :Unite ref/erlang<CR>
noremap <Leader>rm :Unite ref/man<CR>
noremap <Leader>rp :Unite ref/perldoc<CR>
noremap <Leader>rh :Unite ref/phpmanual<CR>
noremap <Leader>ry :Unite ref/pydoc<CR>
noremap <Leader>rr :Unite ref/refe<CR>
noremap <Leader>rv :vert res 80<CR>
autocmd FileType ref call s:initialize_ref_viewer()
function! s:initialize_ref_viewer()
	noremap <buffer><C-T> :Unite tab<CR>
endfunction


