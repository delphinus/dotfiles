function! delphinus#csv#init() abort
  hi CSVColumnEven term=bold cterm=underline ctermfg=0 ctermbg=251 gui=bold,underline guifg=black guibg=grey50
  hi CSVColumnOdd  cterm=underline,reverse ctermfg=174 ctermbg=0 gui=underline guifg=black guibg=grey80
  hi CSVColumnHeaderEven term=bold cterm=standout,underline ctermfg=15 ctermbg=242 gui=bold,underline guifg=black guibg=grey50
  hi CSVColumnHeaderOdd  cterm=standout,underline ctermfg=79 ctermbg=0 gui=bold,underline guifg=black guibg=grey80
endfunction
