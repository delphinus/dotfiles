function! delphinus#init#markdown#hook_add() abort
  augroup SetMarkdown
    autocmd!
    autocmd FileType markdown,howm_memo.markdown setlocal conceallevel=2
    autocmd FileType markdown,howm_memo.markdown hi markdownH1 cterm=bold,italic gui=bold,italic
    autocmd FileType markdown,howm_memo.markdown hi markdownH2 cterm=bold gui=bold
    autocmd FileType markdown,howm_memo.markdown hi markdownH3 cterm=italic gui=italic
  augroup END
endfunction

function! delphinus#init#markdown#hook_source() abort
  let g:markdown_fenced_languages = [
        \ 'coffee',
        \ 'cpp',
        \ 'css',
        \ 'diff',
        \ 'erlang',
        \ 'go',
        \ 'haskell',
        \ 'html',
        \ 'java',
        \ 'javascript',
        \ 'json',
        \ 'lua',
        \ 'ocaml',
        \ 'perl',
        \ 'plantuml',
        \ 'python',
        \ 'ruby',
        \ 'sh',
        \ 'sql',
        \ 'toml',
        \ 'typescript',
        \ 'vim',
        \ ]
  " set conceal feature: default value '#*dlaibBces'
  let g:markdown_conceal = '*dlaibBes'
endfunction
