scriptencoding utf-8
command! SyntaxInfo call delphinus#syntax_info#get_info()

augroup QuickFixWindowHeight
  autocmd!
  autocmd FileType qf call delphinus#quickfix#set_height(3, 10)
  autocmd FileType qf setlocal colorcolumn=
  autocmd WinEnter * if &filetype ==# 'qf' | call delphinus#quickfix#set_height(3, 10) | endif
augroup END

function! s:cleanUpStartUpTime() abort
  let vim = printf('silent! %%s,%s,$VIM,', expand('$VIM'))
  execute vim
  let $DEIN = expand('~/.cache/dein')
  let dein = printf('silent! %%s,%s,$DEIN,', $DEIN)
  execute dein
  let home = printf('silent! %%s,%s,\~', expand('$HOME'))
  execute home
endfunction

command! CleanUpStartUpTime call <SID>cleanUpStartUpTime()

" from denite.nvim
function! s:getchar() abort
  redraw | echo 'Press any key: '
  let c = getchar()
  while c ==# "\<CursorHold>"
    redraw | echo 'Press any key: '
    let c = getchar()
  endwhile
  redraw | echomsg printf('Raw: "%s" | Char: "%s"', c, nr2char(c))
endfunction
command! GetChar call s:getchar()

command! UpdateExtraGoCommand call delphinus#go#install_tester_binaries(1)
command! InstallExtraGoCommand call delphinus#go#install_tester_binaries(0)
