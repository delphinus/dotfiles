scriptencoding utf-8
command! SyntaxInfo call delphinus#syntax_info#get_info()

augroup QuickFixWindowHeight
  autocmd!
  autocmd FileType qf call delphinus#quickfix#set_height(3, 10)
  autocmd FileType qf setlocal colorcolumn=
  autocmd WinEnter * if &filetype ==# 'qf' | call delphinus#quickfix#set_height(3, 10) | endif
augroup END

function s:cleanUpStartUpTime() abort
  let l:vim = printf('%%s,%s,$VIM,', expand('$VIM'))
  execute l:vim
  let $DEIN = expand('~/.cache/dein')
  let l:dein = printf('%%s,%s,$DEIN,', $DEIN)
  execute l:dein
  let l:home = printf('%%s,%s,\~', expand('$HOME'))
  execute l:home
endfunction

command! CleanUpStartUpTime call <SID>cleanUpStartUpTime()
