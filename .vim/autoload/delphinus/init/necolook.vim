function! delphinus#init#necolook#hook_add() abort
  let g:neocomplete#text_mode_filetypes = {
        \ 'rst': 1,
        \ 'markdown': 1,
        \ 'howm_memo': 1,
        \ 'howm_memo.markdown': 1,
        \ 'gitrebase': 1,
        \ 'gitcommit': 1,
        \ 'vcs-commit': 1,
        \ 'hybrid': 1,
        \ 'text': 1,
        \ 'help': 1,
        \ 'tex': 1,
        \ }

  if dein#tap('neocomplete.vim')
    execute 'autocmd MyAutoCmd User' 'dein#source#'.g:dein#name
          \ 'call s:set_source()'
  endif
endfunction

function! s:set_source() abort
  call neocomplete#custom#source('look', 'min_pattern_length', 1)
endfunction
