scriptencoding utf-8
command! SyntaxInfo call delphinus#syntax_info#get_info()

augroup QuickFixWindowHeight
  autocmd!
  autocmd FileType qf call delphinus#quickfix#set_height(3, 10)
  autocmd FileType qf setlocal colorcolumn=
  autocmd WinEnter * if &filetype ==# 'qf' | call delphinus#quickfix#set_height(3, 10) | endif
augroup END

function! s:cleanUpStartUpTime() abort
  let l:vim = printf('%%s,%s,$VIM,', expand('$VIM'))
  execute l:vim
  let $DEIN = expand('~/.cache/dein')
  let l:dein = printf('%%s,%s,$DEIN,', $DEIN)
  execute l:dein
  let l:home = printf('%%s,%s,\~', expand('$HOME'))
  execute l:home
endfunction

command! CleanUpStartUpTime call <SID>cleanUpStartUpTime()

" from denite.nvim
function! s:getchar() abort
  redraw | echo 'Press any key: '
  let l:c = getchar()
  while l:c ==# "\<CursorHold>"
    redraw | echo 'Press any key: '
    let l:c = getchar()
  endwhile
  redraw | echomsg printf('Raw: "%s" | Char: "%s"', l:c, nr2char(l:c))
endfunction
command! GetChar call s:getchar()

" for gometalinter
let s:lacked_packages = {
      \ 'dupl':        ['github.com/mibk/dupl'],
      \ 'gocyclo':     ['github.com/alecthomas/gocyclo'],
      \ 'gotype':      ['golang.org/x/tools/cmd/gotype'],
      \ 'ineffassign': ['github.com/gordonklaus/ineffassign'],
      \ 'gas':         ['github.com/GoASTScanner/gas'],
      \ 'lll':         ['github.com/walle/lll/cmd/lll'],
      \ 'goconst':     ['github.com/jgautheron/goconst/cmd/goconst'],
      \ 'misspell':    ['github.com/client9/misspell/cmd/misspell'],
      \ }
function! s:installGoTesterBinaries(isUpdate) abort
  let l:opt = a:isUpdate ? '-u' : ''
  for [l:binary, l:pkg] in items(s:lacked_packages)
    if !a:isUpdate && executable(l:binary)
      echo l:binary . ' is already installed'
      continue
    endif
    for l:p in l:pkg
      let l:cmd = printf('go get %s %s', l:opt, shellescape(l:p))
      echo l:cmd
      call system(l:cmd)
    endfor
  endfor
endfunction
command! UpdateExtraGoCommand call s:installGoTesterBinaries(1)
command! InstallExtraGoCommand call s:installGoTesterBinaries(0)
