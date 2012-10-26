" for Tokyo
let g:sunset_latitude = 35.67
let g:sunset_longitude = 139.8
let g:sunset_utc_offset = 9

function! g:sunset_callback()
	if exists(':PowerlineReloadColorscheme')
		let g:Powerline_colorscheme = &background == 'light' ? 'solarizedLight' : 'solarizedDark'
		PowerlineReloadColorscheme
	endif
endfunction
