scriptencoding utf-8

function! delphinus#init#ref#hook_source() abort
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
