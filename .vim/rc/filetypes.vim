augroup FiletypeSetting
  autocmd!
  autocmd FileType help nnoremap <buffer>q :q<CR>
  autocmd FileType applescript :inoremap <buffer> <S-CR> ￢<CR>
augroup END
