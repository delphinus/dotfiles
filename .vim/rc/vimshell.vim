"-----------------------------------------------------------------------------
" VimShell
" プロンプトにカレントディレクトリを表示
let g:vimshell_user_prompt = 'getcwd()'
" 初期化ファイルの場所を指定
if is_office
	let g:vimshell_vimshrc_path=expand('$H/.vimshrc')
else
	let g:vimshell_vimshrc_path=expand('$HOME/.vimshrc')
endif
nnoremap <Leader>vv :VimShell<CR>
nnoremap <Leader>vc :VimShellCreate<CR>
nnoremap <Leader>vt :VimShellTab<CR>
autocmd FileType vimshell noremap <buffer><C-P> :Unite buffer_tab file_mru<CR>
autocmd FileType vimshell noremap <buffer><C-N> :UniteWithBufferDir -buffer-name=files file<CR>
autocmd FileType vimshell noremap <buffer><C-X><C-P> <Plug>(vimshell_int_previous_prompt)
autocmd FileType vimshell noremap <buffer><C-X><C-N> <Plug>(vimshell_int_next_prompt)
autocmd FileType vimshell nnoremap <buffer><C-K> <C-W><C-K>
autocmd FileType vimshell nnoremap <buffer><C-L> <C-W><C-L>
autocmd FileType vimshell nnoremap <buffer><C-X><C-K> <Plug>(vimshell_delete_previous_output)
autocmd FileType vimshell nnoremap <buffer><C-X><C-L> <Plug>(vimshell_clear)
autocmd FileType vimshell nnoremap <buffer><C-T> :Unite tab<CR>
autocmd FileType vimshell inoremap <buffer><C-T> <ESC>:Unite tab<CR>


