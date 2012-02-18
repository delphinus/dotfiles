function s:URLEncode()
	let l:line = getline('.')
	let l:encoded = AL_urlencode(l:line)
	call setline('.', l:encoded)
endfunction

function s:URLDecode()
	let l:line = getline('.')
	let l:decoded = AL_urldecode(l:line)
	call setline('.', l:decoded)
endfunction

command! -nargs=0 -range URLEncode :<line1>,<line2>call <SID>URLEncode()
command! -nargs=0 -range URLDecode :<line1>,<line2>call <SID>URLDecode()
