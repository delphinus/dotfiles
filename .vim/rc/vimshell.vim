"-----------------------------------------------------------------------------
" VimShell
" プロンプトにカレントディレクトリを表示
let g:vimshell_user_prompt = 'getcwd()'
" 初期化ファイルの場所を指定
let g:vimshell_vimshrc_path = g:home . '/.vimshrc'
" 履歴ファイルなどの場所を指定
let g:vimshell_temporary_directory = g:home . '/.vimshell'
" 大文字小文字を区別しない？
let g:vimshell_enable_smart_case = 1

" vimshell を開くマップ
nnoremap <Leader>vv :VimShell<CR>
nnoremap <Leader>vc :VimShellCreate<CR>
nnoremap <Leader>vt :VimShellTab<CR>
" unite.vim 連携
"autocmd FileType vimshell nnoremap <buffer><C-P> :Unite buffer_tab file_mru<CR>
"autocmd FileType vimshell nnoremap <buffer><C-N> :UniteWithBufferDir -buffer-name=files file file/new<CR>
" コマンドプロンプト移動
"autocmd FileType vimshell nnoremap <buffer><C-X><C-P> <Plug>(vimshell_previous_prompt)
"autocmd FileType vimshell nnoremap <buffer><C-X><C-N> <Plug>(vimshell_next_prompt)
" ウィンドウ移動
"autocmd FileType vimshell nnoremap <buffer><C-K> <C-W><C-K>
"autocmd FileType vimshell nnoremap <buffer><C-L> <C-W><C-L>
" デフォルトの動作
"autocmd FileType vimshell nnoremap <buffer><C-X><C-K> <Plug>(vimshell_delete_previous_output)
"autocmd FileType vimshell nnoremap <buffer><C-X><C-L> <Plug>(vimshell_clear)
" タブで開く
autocmd FileType vimshell nnoremap <buffer><C-T> :Unite tab<CR>
autocmd FileType vimshell inoremap <buffer><C-T> <ESC>:Unite tab<CR>
" 履歴補完はノーマルモードで
autocmd FileType vimshell inoremap <buffer> <expr><silent> <C-l>  unite#sources#vimshell_history#start_complete(0)


