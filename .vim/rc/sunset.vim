" for Tokyo
let g:sunset_latitude = 35.67
let g:sunset_longitude = 139.8
let g:sunset_utc_offset = 9

let g:sunset_last_background = ''
function! g:sunset_callback()
	if g:sunset_last_background != &bg && exists(':PowerlineReloadColorscheme')
		let g:sunset_last_background = &bg
		let g:Powerline_colorscheme = &background == 'light' ? 'solarizedLight' : 'solarizedDark'
		PowerlineReloadColorscheme
	endif
endfunction
