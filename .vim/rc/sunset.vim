" for Tokyo
let g:sunset_latitude = 35.67
let g:sunset_longitude = 139.8
let g:sunset_utc_offset = 9

function! g:sunset_daytime_callback()
    set background=light
endfunction

function! g:sunset_nighttime_callback()
    set background=dark
endfunction
