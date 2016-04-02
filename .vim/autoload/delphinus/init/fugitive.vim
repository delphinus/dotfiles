function! delphinus#init#fugitive#hook_add() abort
  let g:fugitive_git_executable = expand('HOME=$H git my-alias')
  nnoremap git :<c-u>Git
  nnoremap g<space> :<c-u>Git 
  nnoremap gs :<c-u>Gstatus<CR>
  nnoremap d< :diffget //2<CR>
  nnoremap d> :diffget //3<CR>
endfunction
