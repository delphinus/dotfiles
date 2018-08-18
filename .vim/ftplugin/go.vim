if dein#is_sourced('vim-go')
  if &background ==# 'light'
    hi! goSameId term=bold cterm=bold ctermbg=225 guibg=#eeeaec
  else
    hi! goSameId term=bold ctermbg=23 ctermfg=7 guifg=#eee8d5 guibg=#00533f
  endif
endif
