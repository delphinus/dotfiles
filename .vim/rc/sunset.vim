" for Tokyo
let g:sunset_latitude = 35.67
let g:sunset_longitude = 139.8
let g:sunset_utc_offset = 9

function! g:sunset_daytime_callback()
    set background=light
    if has('gui')
        colorscheme hemisu
    else
        colorscheme seoul256-light
    endif
endfunction

function! g:sunset_nighttime_callback()
    set background=dark
    if has('gui')
        colorscheme hemisu
    else
        colorscheme seoul256
    endif
endfunction
