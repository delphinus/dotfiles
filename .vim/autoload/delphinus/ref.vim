scriptencoding utf-8

let s:V = vital#of('vital')
let s:P = s:V.import('Prelude')

function! delphinus#ref#before_init() abort
  noremap `rm :Unite ref/man<CR>
  noremap `rp :Unite ref/perldoc<CR>
  noremap `rr :Unite ref/refe<CR>
endfunction

function! delphinus#ref#init() abort
  let g:ref_open=':vsp'
  let g:ref_alc_start_linenumber=42

  " <Plug>(ref-source-perldoc-switch) を再定義
  augroup vimrc-plugin-ref
      autocmd!
      autocmd FileType ref nnoremap <silent> <buffer> <expr> O
                  \ b:ref_source ==# 'perldoc' ?
                  \ ":\<C-u>call delphinus#ref#perl_module_edit()\<CR>" : "\<Nop>"
      autocmd FileType ref nnoremap <silent> <buffer> <expr> o
                  \ b:ref_source ==# 'perldoc' ?
                  \ (b:ref_perldoc_mode ==# 'module' ? ":\<C-u>Ref perldoc -m " .
                  \   b:ref_perldoc_word . "\<CR>" :
                  \  b:ref_perldoc_mode ==# 'source' ? ":\<C-u>Ref perldoc " .
                  \   b:ref_perldoc_word . "\<CR>" :
                  \ 's') : 's'
  augroup END
endfunction

function! delphinus#ref#perl_module_edit(...) abort
  if a:0 > 0
    let module = a:1
  elseif exists('b:ref_perldoc_word')
    let module = b:ref_perldoc_word
  else
    echo 'No module specified'
    return
  endif

  let perldoc_cmd = s:P.is_string(g:ref_perldoc_cmd) ? split(g:ref_perldoc_cmd, '\s\+') : g:ref_perldoc_cmd
  let res = ref#system(perldoc_cmd + ['-l', module])

  if res.stdout ==# ''
    echo printf('No module found for "%s".', module)
  else
    execute 'edit ' . res.stdout
  endif
endfunction
