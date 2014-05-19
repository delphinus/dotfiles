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

" <Plug>(ref-source-perldoc-switch) を再定義
augroup vimrc-plugin-ref
    autocmd!
    autocmd FileType ref nnoremap <silent> <buffer> <expr> O
                \ b:ref_source ==# 'perldoc' ?
                \ ":\<C-u>call RefPerlModuleEdit()\<CR>" : "\<Nop>"
    autocmd FileType ref nnoremap <silent> <buffer> <expr> o
                \ b:ref_source ==# 'perldoc' ?
                \ (b:ref_perldoc_mode ==# 'module' ? ":\<C-u>Ref perldoc -m " .
                \   b:ref_perldoc_word . "\<CR>" :
                \  b:ref_perldoc_mode ==# 'source' ? ":\<C-u>Ref perldoc " .
                \   b:ref_perldoc_word . "\<CR>" :
                \ 's') : 's'
augroup END

" ------------------------------------------------------------------------------
" http://www.karakaram.com/ref-webdict
"webdictサイトの設定
let g:ref_source_webdict_sites = {
\   'je': {
\     'url': 'http://dictionary.infoseek.ne.jp/jeword/%s',
\   },
\   'ej': {
\     'url': 'http://dictionary.infoseek.ne.jp/ejword/%s',
\   },
\   'wiki': {
\     'url': 'http://ja.wikipedia.org/wiki/%s',
\   },
\ }

"デフォルトサイト
let g:ref_source_webdict_sites.default = 'ej'

"出力に対するフィルタ。最初の数行を削除
function! g:ref_source_webdict_sites.je.filter(output)
  return join(split(a:output, "\n")[15 :], "\n")
endfunction
function! g:ref_source_webdict_sites.ej.filter(output)
  return join(split(a:output, "\n")[15 :], "\n")
endfunction
function! g:ref_source_webdict_sites.wiki.filter(output)
  return join(split(a:output, "\n")[17 :], "\n")
endfunction

noremap <Leader>rj :<C-u>Ref webdict je<Space>
noremap <Leader>re :<C-u>Ref webdict ej<Space>
