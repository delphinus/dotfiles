"-----------------------------------------------------------------------------
"" 時刻表示形式 → (月) 01/02 午後 03:45
let g:unite_source_file_mru_time_format='(%a) %m/%d %p %I:%M '

" データファイル
if is_office
    let g:unite_data_directory = expand('$H/.unite')
endif
noremap <C-P> :Unite buffer_tab file_mru<CR>
noremap <C-N> :UniteWithBufferDir -buffer-name=files file file/new<CR>
noremap <Leader>ur :Unite file_rec/async<CR>
noremap <C-Z> :Unite outline<CR>
noremap <C-T> :Unite tab<CR>
noremap <Leader>uu :Unite bookmark<CR>
noremap <Leader>uc :Unite colorscheme<CR>
noremap <Leader>ul :Unite locate<CR>
noremap <Leader>uv :Unite buffer -input=vimshell<CR>
noremap <Leader>vu :Unite buffer -input=vimshell<CR>
autocmd FileType unite call s:unite_my_settings()
call unite#set_substitute_pattern('files', '\$\w\+', '\=eval(submatch(0))', 200)
call unite#set_substitute_pattern('files', '^@@', '\=fnamemodify(expand("#"), ":p:h")."/"', 2)
call unite#set_substitute_pattern('files', '^@', '\=getcwd()."/*"', 1)
call unite#set_substitute_pattern('files', '^;r', '\=$VIMRUNTIME."/"')
call unite#set_substitute_pattern('files', '^\~', escape($HOME, '\'), -2)
call unite#set_substitute_pattern('files', '\\\@<! ', '\\ ', -20)
call unite#set_substitute_pattern('files', '\\ \@!', '/', -30)
if is_office
    call unite#set_substitute_pattern('files', '^;h', '\=$H."/"')
    call unite#set_substitute_pattern('files', '^;j', '\=$J."/"')
    call unite#set_substitute_pattern('files', '^;d', '\=$D."/"')
    call unite#set_substitute_pattern('files', '^;p', '\=$P."/"')
    call unite#set_substitute_pattern('files', '^;v', '\=$H."/.vim/"')
else
    call unite#set_substitute_pattern('files', '^;v', '~/.vim/')
endif
if has('win32') || has('win64')
  call unite#set_substitute_pattern('files', '^;p', 'C:/Program Files/')
endif

" vcscommand.vim の diff buffer を消す
call unite#custom_filters('buffer,buffer_tab',
            \ ['matcher_default', 'sorter_default', 'converter_erase_diff_buffer'])

" 大文字小文字を区別しない
call unite#set_profile('files', 'ignorecase', 1)
call unite#set_profile('file_mru', 'ignorecase', 1)

function! s:unite_my_settings()
    " 上下に分割して開く
    nnoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
    inoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
    " 左右に分割して開く
    nnoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
    inoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
    " タブで開く
    nnoremap <silent> <buffer> <expr> <C-T> unite#do_action('tabopen')
    inoremap <silent> <buffer> <expr> <C-T> unite#do_action('tabopen')
    " vimfiler で開く
    nnoremap <silent> <buffer> <expr> <C-O> unite#do_action('vimfiler')
    inoremap <silent> <buffer> <expr> <C-O> unite#do_action('vimfiler')
    " 終了
    nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
    inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>
endfunction


