au BufNewFile,BufRead * call s:detectFT()

function! s:detectFT()
  if len(&ft) == 0
    let s:matched = matchstr(getline(1), '^#!\%(.*/bin/\%(env\s\+\)\?\)\zs[a-zA-Z]\+')
    if len(s:matched) > 0
      if s:matched =~# 'sh$'
        setf sh
      else
        execute 'setf' s:matched
      endif
    endif
  endif
endfunction
