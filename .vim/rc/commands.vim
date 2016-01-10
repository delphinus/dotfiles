scriptencoding utf-8
command! SyntaxInfo call delphinus#syntax_info#get_info()

augroup QuickFixWindowHeight
  autocmd!
  autocmd FileType qf call delphinus#quickfix#set_height(3, 10)
  autocmd WinEnter * if &filetype ==# 'qf' | call delphinus#quickfix#set_height(3, 10) | endif
augroup END

" 'cursorcolumn' を必要な時にだけ有効にする - 永遠に未完成
" http://d.hatena.ne.jp/thinca/20090530/1243615055
augroup vimrc-auto-cursorcolumn
  autocmd!
  autocmd CursorMoved,CursorMovedI * call s:auto_cursorcolumn('CursorMoved')
  autocmd CursorHold,CursorHoldI * call s:auto_cursorcolumn('CursorHold')
  autocmd WinEnter * call s:auto_cursorcolumn('WinEnter')
  autocmd WinLeave * call s:auto_cursorcolumn('WinLeave')

  let s:cursorcolumn_lock = 0
  function! s:auto_cursorcolumn(event)
    if a:event ==# 'WinEnter'
      setlocal cursorcolumn
      let s:cursorcolumn_lock = 2
    elseif a:event ==# 'WinLeave'
      setlocal nocursorcolumn
    elseif a:event ==# 'CursorMoved'
      if s:cursorcolumn_lock
        if 1 < s:cursorcolumn_lock
          let s:cursorcolumn_lock = 1
        else
          setlocal nocursorcolumn
          let s:cursorcolumn_lock = 0
        endif
      endif
    elseif a:event ==# 'CursorHold'
      setlocal cursorcolumn
      let s:cursorcolumn_lock = 1
    endif
  endfunction
augroup END
