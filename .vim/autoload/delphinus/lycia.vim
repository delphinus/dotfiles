function! delphinus#lycia#init()
  nmap go <Plug>(lycia)
  vmap go <Plug>(lycia)
  nmap gb <Plug>(lycia-current-branch)
  vmap gb <Plug>(lycia-current-branch)
  nmap gc <Plug>(lycia-current-commit)
  vmap gc <Plug>(lycia-current-commit)
  nmap g<C-t> <Plug>(lycia-top-page)
  nmap g<C-y> <Plug>(lycia-top-page-current-branch)
  let g:lycia_map=0
endfunction
