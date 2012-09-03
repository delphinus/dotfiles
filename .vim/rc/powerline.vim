"-----------------------------------------------------------------------------
" vim-powerline
let g:Powerline_symbols = 'fancy'
let g:Powerline_theme = 'default'
let g:Powerline_colorscheme = 'solarizedDark'

if is_office_alt
	let g:Powerline_colorscheme = 'solarizedLight'
elseif is_office
	let g:Powerline_colorscheme = 'default'
else
	let g:Powerline_colorscheme = 'solarizedDark'
endif
