" functions {{{
" returns an approximate grey index for the given grey level
fun <SID>grey_number(x)
	if &t_Co == 88
		if a:x < 23
			return 0
		elseif a:x < 69
			return 1
		elseif a:x < 103
			return 2
		elseif a:x < 127
			return 3
		elseif a:x < 150
			return 4
		elseif a:x < 173
			return 5
		elseif a:x < 196
			return 6
		elseif a:x < 219
			return 7
		elseif a:x < 243
			return 8
		else
			return 9
		endif
	else
		if a:x < 14
			return 0
		else
			let n = (a:x - 8) / 10
			let m = (a:x - 8) % 10
			if m < 5
				return n
			else
				return n + 1
			endif
		endif
	endif
endfun

" returns the actual grey level represented by the grey index
fun <SID>grey_level(n)
	if &t_Co == 88
		if a:n == 0
			return 0
		elseif a:n == 1
			return 46
		elseif a:n == 2
			return 92
		elseif a:n == 3
			return 115
		elseif a:n == 4
			return 139
		elseif a:n == 5
			return 162
		elseif a:n == 6
			return 185
		elseif a:n == 7
			return 208
		elseif a:n == 8
			return 231
		else
			return 255
		endif
	else
		if a:n == 0
			return 0
		else
			return 8 + (a:n * 10)
		endif
	endif
endfun

" returns the palette index for the given grey index
fun <SID>grey_color(n)
	if &t_Co == 88
		if a:n == 0
			return 16
		elseif a:n == 9
			return 79
		else
			return 79 + a:n
		endif
	else
		if a:n == 0
			return 16
		elseif a:n == 25
			return 231
		else
			return 231 + a:n
		endif
	endif
endfun

" returns an approximate color index for the given color level
fun <SID>rgb_number(x)
	if &t_Co == 88
		if a:x < 69
			return 0
		elseif a:x < 172
			return 1
		elseif a:x < 230
			return 2
		else
			return 3
		endif
	else
		if a:x < 75
			return 0
		else
			let n = (a:x - 55) / 40
			let m = (a:x - 55) % 40
			if m < 20
				return n
			else
				return n + 1
			endif
		endif
	endif
endfun

" returns the actual color level for the given color index
fun <SID>rgb_level(n)
	if &t_Co == 88
		if a:n == 0
			return 0
		elseif a:n == 1
			return 139
		elseif a:n == 2
			return 205
		else
			return 255
		endif
	else
		if a:n == 0
			return 0
		else
			return 55 + (a:n * 40)
		endif
	endif
endfun

" returns the palette index for the given R/G/B color indices
fun <SID>rgb_color(x, y, z)
	if &t_Co == 88
		return 16 + (a:x * 16) + (a:y * 4) + a:z
	else
		return 16 + (a:x * 36) + (a:y * 6) + a:z
	endif
endfun

" returns the palette index to approximate the given R/G/B color levels
fun <SID>color(r, g, b)
	" get the closest grey
	let gx = <SID>grey_number(a:r)
	let gy = <SID>grey_number(a:g)
	let gz = <SID>grey_number(a:b)

	" get the closest color
	let x = <SID>rgb_number(a:r)
	let y = <SID>rgb_number(a:g)
	let z = <SID>rgb_number(a:b)

	if gx == gy && gy == gz
		" there are two possibilities
		let dgr = <SID>grey_level(gx) - a:r
		let dgg = <SID>grey_level(gy) - a:g
		let dgb = <SID>grey_level(gz) - a:b
		let dgrey = (dgr * dgr) + (dgg * dgg) + (dgb * dgb)
		let dr = <SID>rgb_level(gx) - a:r
		let dg = <SID>rgb_level(gy) - a:g
		let db = <SID>rgb_level(gz) - a:b
		let drgb = (dr * dr) + (dg * dg) + (db * db)
		if dgrey < drgb
			" use the grey
			return <SID>grey_color(gx)
		else
			" use the color
			return <SID>rgb_color(x, y, z)
		endif
	else
		" only one possibility
		return <SID>rgb_color(x, y, z)
	endif
endfun

" returns the palette index to approximate the 'rrggbb' hex string
fun <SID>rgb(rgb)
	let r = ('0x' . strpart(a:rgb, 0, 2)) + 0
	let g = ('0x' . strpart(a:rgb, 2, 2)) + 0
	let b = ('0x' . strpart(a:rgb, 4, 2)) + 0
	return <SID>color(r, g, b)
endfun

" sets the highlighting for the given group
fun <SID>X(group, fg, bg, attr)
	if a:fg !=# ''
		exec 'hi '.a:group.' guifg=#'.a:fg.' ctermfg='.<SID>rgb(a:fg)
	endif
	if a:bg !=# ''
		exec 'hi '.a:group.' guibg=#'.a:bg.' ctermbg='.<SID>rgb(a:bg)
	endif
	if a:attr !=# ''
		if a:attr ==# 'italic'
			exec 'hi '.a:group.' gui='.a:attr.' cterm=none'
		else
			exec 'hi '.a:group.' gui='.a:attr.' cterm='.a:attr
		endif
	endif
endfun
" }}}


" returns the palette index to approximate the 'rrggbb' hex string
fun RGB(rgb)
	let r = ('0x' . strpart(a:rgb, 0, 2)) + 0
	let g = ('0x' . strpart(a:rgb, 2, 2)) + 0
	let b = ('0x' . strpart(a:rgb, 4, 2)) + 0
	return <SID>color(r, g, b)
endfun
