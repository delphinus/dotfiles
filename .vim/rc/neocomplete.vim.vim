" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Select with <TAB>
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

let g:neocomplete#ctags_arguments = {
            \ 'perl': '-R -h ".pm"'
            \ }
"let g:neocomplete_snippets_dir = g:home . '/vim/snippets'
" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
            \ 'default': '',
            \ 'perl': g:home . '/.vim/dict/perl.dict'
            \ }

" Define keyword.
if !exists('g:neocomplete#sources#dictionary#keyword_patterns')
  let g:neocomplete#sources#dictionary#keyword_patterns = {}
endif
let g:neocomplete#sources#dictionary#keyword_patterns['default'] = '\h\w*'

" for snippets
"imap <expr><C-k> neocomplete#sources#snippets_complete#expandable() ? "\<Plug>(neocomplete_snippets_expand)" : "\<C-n>"
"smap <C-k> <Plug>(neocomplete_snippets_expand)

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
"autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '\%(\.\|->\)\h\w*'
"let g:neocomplete#sources#omni#input_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

" Disable neocomplete in objc filetype
let g:neocomplete#sources#omni#input_patterns['objc'] = ''

if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif
"let g:neocomplete#force_omni_input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
let g:neocomplete#sources#rsense#home_directory = '/usr/local/bin/rsense'
