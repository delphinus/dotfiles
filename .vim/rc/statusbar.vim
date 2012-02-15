"-----------------------------------------------------------------------------
" ステータスバー設定
"-----------------------------------------------------------------------------
set laststatus=2
hi User1 term=NONE cterm=NONE ctermfg=black ctermbg=blue
hi User2 term=NONE cterm=NONE ctermfg=black ctermbg=magenta
hi User3 term=NONE cterm=NONE ctermfg=black ctermbg=red
hi User4 term=NONE cterm=NONE ctermfg=black ctermbg=green
hi User5 term=NONE cterm=NONE ctermfg=black ctermbg=cyan
hi User6 term=NONE cterm=NONE ctermfg=black ctermbg=cyan
hi User7 term=NONE cterm=NONE ctermfg=black ctermbg=cyan
hi User8 term=NONE cterm=NONE ctermfg=black ctermbg=yellow

"set statusline=
"set statusline+=%*%1*%w
"set statusline+=%y
"set statusline+=%2*%{GetStatusEx()}
"set statusline+=%8*[\ %{GetCurrentDir()}\ ]
"set statusline+=%*\ %t\ %*
"set statusline+=%3*%m
"set statusline+=%4*%r
"set statusline+=%*%=
"set statusline+=%5*R%4l\/%4P\ %6*C%3c%3V
"set statusline+=%7*[CODE\ %04B]
"set statusline+=%*

function! GetStatusEx()
  let str = ''
  let str = str . '' . &fileformat . ']'
  if has('multi_byte') && &fileencoding != ''
    let str = '[' . &fileencoding . ':' . str

  else
    let str = '[' . str
  endif
  return str
endfunction
function! GetCurrentDir()
  let str = ''
  let str = str . expand('%:p:h')
  let str = substitute(str, expand('$H'), '$H', '')
  let str = substitute(str, expand('$HOME'), '~', '')
  if len(str) > winwidth(1) / 3
    " バックスラッシュに囲まれた部分の最初の一文字にマッチするパターン
    let str = substitute(str, '\v%(/)@<=([^/]{2}).{-}%(/)@=', '\1', 'g')
  endif
  return str
endfunction

function! MyHL ()
    set cursorline
    hi User1 term=NONE cterm=NONE ctermfg=black ctermbg=blue    guifg=white guibg=darkblue      gui=bold
    hi User2 term=NONE cterm=NONE ctermfg=black ctermbg=magenta guifg=white guibg=darkmagenta   gui=bold
    hi User3 term=NONE cterm=NONE ctermfg=black ctermbg=red     guifg=white guibg=darkred       gui=bold
    hi User4 term=NONE cterm=NONE ctermfg=black ctermbg=green   guifg=white guibg=darkgreen     gui=bold
    hi User5 term=NONE cterm=NONE ctermfg=black ctermbg=cyan    guifg=white guibg=blueviolet    gui=bold
    hi User6 term=NONE cterm=NONE ctermfg=black ctermbg=cyan    guifg=white guibg=blueviolet    gui=bold
    hi User7 term=NONE cterm=NONE ctermfg=black ctermbg=cyan    guifg=white guibg=darkcyan      gui=bold
    hi User8 term=NONE cterm=NONE ctermfg=black ctermbg=cyan    guifg=white guibg=darkslategray gui=bold
    "hi Cursor guifg=White guibg=mediumorchid
    hi CursorIM guifg=black guibg=darkred
    "if &background == 'dark'
        "hi CursorLine guibg=gray10
    "else
        "hi CursorLine guibg=khaki
    "endif
    hi lCursor guifg=white guibg=Cyan
    hi iCursor guifg=black guibg=blue
    hi rCursor guifg=white guibg=red
    hi oCursor guifg=white guibg=DarkSlateGrey
    hi vCursor guifg=white guibg=orange
    hi sCursor guifg=white guibg=darkred
endfunction
"call MyHL()
"au ColorScheme * call MyHL()

