" for Tokyo
let g:sunset_latitude = 35.67
let g:sunset_longitude = 139.8
let g:sunset_utc_offset = 9

function! g:sunset_daytime_callback()
    if exists(':PowerlineReloadColorscheme')
        let g:Powerline_colorscheme = 'solarized'
        PowerlineReloadColorscheme
    endif
endfunction

function! g:sunset_nighttime_callback()
    if exists(':PowerlineReloadColorscheme')
        let g:Powerline_colorscheme = 'solarized16'
        PowerlineReloadColorscheme
    endif
endfunction
