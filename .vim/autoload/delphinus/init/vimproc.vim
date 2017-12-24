function! delphinus#init#vimproc#hook_post_update() abort
  if dein#util#_is_windows()
    let l:cmd = 'tools\\update-dll-mingw'
  elseif dein#util#_is_cygwin()
    let l:cmd = 'make -f make_cygwin.mak'
  elseif executable('gmake')
    let l:cmd = 'gmake'
  else
    let l:cmd = 'make'
  endif
  let g:dein#plugin.build = l:cmd
endfunction
