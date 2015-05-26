if exists('$H')
  let g:fugitive_git_executable = 'HOME=$H git'
endif
nnoremap git :<c-u>Git
nnoremap g<space> :<c-u>Git 
nnoremap gs :<c-u>Gstatus<CR>
