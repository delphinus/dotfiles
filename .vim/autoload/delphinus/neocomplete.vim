function! delphinus#neocomplete#before_init() abort
  " Enable omni completion.
  augroup NeocompleteFileType
    autocmd!
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  augroup END
endfunction

function! delphinus#neocomplete#init() abort
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#min_keyword_length = 3
  inoremap <expr><TAB>
        \ neocomplete#complete_common_string() != '' ?
        \   neocomplete#complete_common_string() :
        \ pumvisible() ? "\<C-n>" : "\<TAB>"

  " Define dictionary.
  let g:neocomplete#sources#dictionary#dictionaries = {
              \ 'default': '',
              \ 'perl': g:home . '/.vim/dict/perl.dict'
              \ }

  " Define keyword.
  let g:neocomplete#keyword_patterns = get(g:, 'neocomplete#keyword_patterns', {})
  let g:neocomplete#keyword_patterns.default = '\h\w*'

  " Enable heavy omni completion.
  let g:neocomplete#sources#omni#input_patterns = get(g:, 'neocomplete#sources#omni#input_patterns', {})
  let g:neocomplete#force_omni_input_patterns = get(g:, 'neocomplete#force_omni_input_patterns', {})
  let g:neocomplete#force_omni_input_patterns.go = '[^.[:digit:] *\t]\.\w*'
  let g:neocomplete#force_omni_input_patterns.typescript = '[^. \t]\.\%(\h\w*\)\?'
endfunction
