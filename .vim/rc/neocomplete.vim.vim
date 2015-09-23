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
if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns.default = '\h\w*'

" Enable omni completion.
augroup NeocompleteFileType
  autocmd!
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
augroup END

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.go = '[^.[:digit:] *\t]\.\w*'
