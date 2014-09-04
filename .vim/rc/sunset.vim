" for Tokyo
let g:sunset_latitude = 35.67
let g:sunset_longitude = 139.8
let g:sunset_utc_offset = 9

function g:SunsetDaytimeCallback()
  set background=light
  highlight Error term=bold cterm=bold ctermbg=1 ctermfg=7 guifg=White guibg=Red
endfunction

function g:SunsetNighttimeCallback()
  set background=dark
  highlight Error term=bold cterm=bold ctermbg=1 ctermfg=0 guifg=Black guibg=Red
endfunction
