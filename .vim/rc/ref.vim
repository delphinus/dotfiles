"-----------------------------------------------------------------------------
" vim-ref
let g:ref_open=':vsp'
let g:ref_alc_start_linenumber=42
noremap <Leader>rm :Unite ref/man<CR>
noremap <Leader>rp :Unite ref/perldoc<CR>
autocmd FileType ref call s:initialize_ref_viewer()
function! s:initialize_ref_viewer()
    noremap <buffer><C-T> :Unite tab<CR>
endfunction

function! RefPerlModuleEdit(...)
    if a:0 > 0
        let module = a:1
    elseif exists('b:ref_perldoc_word')
        let module = b:ref_perldoc_word
    else
        echo 'No module specified'
        return
    endif

    let res = ref#system((type(g:ref_perldoc_cmd) == type('') ?
                \ split(g:ref_perldoc_cmd, '\s\+') : g:ref_perldoc_cmd)
                \ + ['-l', module])
    if res.stdout == ''
        echo printf('No module found for "%s".', module)
        return
    endif

    execute 'edit ' . res.stdout
endfunction

" <Plug>(ref-source-perldoc-switch) を再定義。yankstack とバッティングするため。
augroup vimrc-plugin-ref
    autocmd!
    autocmd FileType ref vertical resize 80<CR>
    autocmd FileType ref nnoremap <silent> <buffer> <Leader>rv :vert res 80<CR>
    autocmd FileType ref nnoremap <silent> <buffer> <expr> S
                \ b:ref_source ==# 'perldoc' ?
                \ ":\<C-u>call RefPerlModuleEdit()\<CR>" : "\<Nop>"
    autocmd FileType ref nnoremap <silent> <buffer> <expr> s
                \ b:ref_source ==# 'perldoc' ?
                \ (b:ref_perldoc_mode ==# 'module' ? ":\<C-u>Ref perldoc -m " .
                \   b:ref_perldoc_word . "\<CR>" :
                \  b:ref_perldoc_mode ==# 'source' ? ":\<C-u>Ref perldoc " .
                \   b:ref_perldoc_word . "\<CR>" :
                \ 's') : 's'
augroup END
