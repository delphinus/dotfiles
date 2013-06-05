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
" キーマッピングを戻す
autocmd FileType vimshell nnoremap <buffer><c-j> <c-w>w
autocmd FileType vimshell nnoremap <buffer><c-k> <c-w>W
autocmd FileType vimshell nnoremap <buffer><c-c> <Plug>DWMClose
autocmd FileType vimshell nnoremap <buffer><c-n> <Plug>DWMNew
autocmd FileType vimshell nnoremap <buffer><m-c> <Plug>(vimshell_hangup)
" 履歴補完はノーマルモードで
autocmd FileType vimshell inoremap <buffer> <expr><silent> <C-l>  unite#sources#vimshell_history#start_complete(0)


