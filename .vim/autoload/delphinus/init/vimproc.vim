function! delphinus#init#vimproc#hook_post_update() abort
  if dein#util#_is_windows()
    let cmd = 'tools\\update-dll-mingw'
  elseif dein#util#_is_cygwin()
    let cmd = 'make -f make_cygwin.mak'
  elseif executable('gmake')
    let cmd = 'gmake'
  else
    let cmd = 'make'
  endif
  let g:dein#plugin.build = cmd
endfunction
