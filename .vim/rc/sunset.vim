" for Tokyo
let g:sunset_latitude = 35.67
let g:sunset_longitude = 139.8
let g:sunset_utc_offset = 9

function! g:sunset_daytime_callback()
    set background=light
    colorscheme hemisu
    highlight ColorColumn term=reverse ctermbg=255 guibg=#FFAFAF
    highlight link EasyMotionTarget Type
    highlight link EasyMotionComment Comment
endfunction

function! g:sunset_nighttime_callback()
    set background=dark
    colorscheme hemisu
    highlight ColorColumn term=reverse ctermbg=233 guibg=#111111
    highlight link EasyMotionTarget Type
    highlight link EasyMotionComment Comment
endfunction
