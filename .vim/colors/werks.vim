" Vim color file
" inspired by the desert color scheme by Hans Fugal <hans[AT]fugal[DOT]net>
" Maintainer:   Bidit Mazumder <biditm[AT]users[DOT]sf[DOT]net>
" Last Change:  May 7, 2012

" background
set background=dark
if version > 580
" remove existing highlighting and set the defaults
    hi clear
    if exists("syntax_on")
" load syntax highlighting defaults, if it's enabled
    syntax reset
    endif
endif

let g:colors_name="werks"


" highlight normal
hi Normal          guifg=#F5E8D3            guibg=#333333


" gui highlight cursor
hi iCursor         guifg=#000000            guibg=#F5E8D3
hi Cursor          guifg=#FFFFFF            guibg=#DAA520

set guicursor+=n-c:blinkwait800-iCursor

set guicursor+=i-v:ver10-Cursor
set guicursor+=r:hor10-Cursor

set guicursor+=ci:ver10-iCursor
set guicursor+=cr:hor10-iCursor

set guicursor+=sm:iCursor
set guicursor+=o:hor50-Error


" highlight groups
hi DiffAdd         guifg=#FAEBD7            guibg=#483D8B
hi DiffChange      guifg=#FAEBD7            guibg=#B03060
hi DiffDelete      guifg=#FAEBD7            guibg=#00595A
hi DiffText        guifg=#FAEBD7            guibg=#D2691E
hi Directory       guifg=#00FFFF
hi ErrorMsg        guifg=#F5F5F5            guibg=#8F0000
hi FoldColumn      guifg=#FFEC8B            guibg=#4D4D4D
hi Folded          guifg=#DAA520            guibg=#4D4D4D
hi IncSearch       guifg=#708090            guibg=#F0E68C
hi LineNr          guifg=#F3F2AE            guibg=#4D4D4D
hi ModeMsg         guifg=#FF4500
hi MoreMsg         guifg=#2E8B57
hi NonText         guifg=#4D4D4D
hi Question        guifg=#90EE90
hi Search          guifg=#F5E8D3            guibg=#708090
hi SignColumn      guifg=#2F4F4F            guibg=#8FBC8F
hi SpecialKey      guifg=#C080D0
hi StatusLine      guifg=#000000            guibg=#C2BFA5            gui=none
hi StatusLineNC    guifg=#666666            guibg=#C2BFA5            gui=none
hi Title           guifg=#F5E8D3
hi VertSplit       guifg=#666666            guibg=#C2BFA5            gui=none
hi Visual          guifg=#FAEBD7            guibg=#74873B            gui=none
hi VisualNOS       guifg=#FFFFFF
hi WarningMsg      guifg=#DC143C
hi WildMenu        guifg=#191970            guibg=#BBBB00
"hi CursorIM
"hi Menu
"hi Scrollbar
"hi Tooltip
"hi Pmenu
"hi PmenuSel
"hi PmenuSbar
"hi PmenuThumb
"hi TabLine
"hi TabLineSel
"hi TabLineFill
"hi CursorColumn
"hi CursorLine

" syntax highlighting groups
hi Error           guifg=#F5F5F5            guibg=#8F0000
hi Ignore          guifg=#666666
hi PreProc         guifg=#CD5C5C
hi Todo            guifg=#F0E68C            guibg=#9400D3
