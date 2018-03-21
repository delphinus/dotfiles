function! delphinus#denite#with_pwd(action) abort
  let l:pwd = get(b:, '__pwd__', '')
  if a:action ==# 'grep'
    call denite#start([{'name': 'grep', 'args': [l:pwd, '', '!']}])
  else
    call denite#start([{'name': a:action, 'args': ['', l:pwd]}])
  endif
endfunction
