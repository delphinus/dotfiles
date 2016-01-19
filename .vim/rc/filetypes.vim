augroup FiletypeSetting
  autocmd!
  autocmd FileType help nnoremap <buffer>q :q<CR>
  autocmd FileType applescript :inoremap <buffer> <S-CR> ￢<CR>
augroup END

augroup NoFiletypeForHugeBuffer
  autocmd!
  autocmd BufRead,BufEnter * if line('$') > 3000 | set filetype= | endif
augroup END
