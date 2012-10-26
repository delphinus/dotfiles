" for Tokyo
let g:sunset_latitude = 35.67
let g:sunset_longitude = 139.8
let g:sunset_utc_offset = 9

let g:last_Powerline_colorscheme = ''
function! g:sunset_callback()
	if exists(':PowerlineReloadColorscheme') && g:last_Powerline_colorscheme != g:Powerline_colorscheme
		let g:Powerline_colorscheme = &background == 'light' ? 'solarizedLight' : 'solarizedDark'
		PowerlineReloadColorscheme
		let g:last_Powerline_colorscheme = g:Powerline_colorscheme
	endif
endfunction
