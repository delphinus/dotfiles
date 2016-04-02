function! delphinus#init#yankround#hook_add() abort
  nmap p <Plug>(yankround-p)
  xmap p <Plug>(yankround-p)
  nmap P <Plug>(yankround-P)
  nmap gp <Plug>(yankround-gp)
  xmap gp <Plug>(yankround-gp)
  nmap gP <Plug>(yankround-gP)
  nmap <c-p> <Plug>(yankround-prev)
  nmap <expr><c-n> yankround#is_active() ? "\<Plug>(yankround-next)" : "\<Plug>DWMNew"
endfunction
