function! delphinus#fontzoom#init() abort
  nmap <unique> <silent> + <Plug>(fontzoom-larger)
  nmap <unique> <silent> - <Plug>(fontzoom-smaller)
  nmap <unique> <silent> <C-ScrollWheelUp> <Plug>(fontzoom-larger)
  nmap <unique> <silent> <C-ScrollWheelDown> <Plug>(fontzoom-smaller)
  let g:fontzoom_no_default_key_mappings=1
endfunction
