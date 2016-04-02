function! delphinus#init#fontzoom#hook_add() abort
  nmap <unique> <silent> + <Plug>(fontzoom-larger)
  nmap <unique> <silent> - <Plug>(fontzoom-smaller)
  nmap <unique> <silent> <C-ScrollWheelUp> <Plug>(fontzoom-larger)
  nmap <unique> <silent> <C-ScrollWheelDown> <Plug>(fontzoom-smaller)
endfunction

function! delphinus#init#fontzoom#hook_source() abort
  let g:fontzoom_no_default_key_mappings=1
endfunction
