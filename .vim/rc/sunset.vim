" for Tokyo
let g:sunset_latitude = 35.67
let g:sunset_longitude = 139.8
let g:sunset_utc_offset = 9

function! g:SunsetDaytimeCallback()
  set background=light
  highlight Error term=bold ctermfg=7 ctermbg=12 gui=bold guifg=#eee8d5 guibg=#dc322f
endfunction

function! g:SunsetNighttimeCallback()
  set background=dark
  highlight Error term=bold ctermfg=0 ctermbg=12 gui=bold guifg=#073642 guibg=#dc322f
endfunction
