" Name: Rhinestones
" Maintainer: Harenome Ranaivoarivony Razanajato <harno.ranaivo@gmail.com>
" Version: 1.0
" Last Change: January 19th 2012
"
" Colourscheme for Vim


set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif
let colors_name="rhinestones"


"" Colours
hi Cursor       guifg=NONE    guibg=#767676 gui=none               ctermbg=243
hi Title        guifg=#f6f3e8 guibg=NONE    gui=bold   ctermfg=254             cterm=bold 
hi Normal       guifg=#ffffff guibg=#262626 gui=none   ctermfg=255 ctermbg=235
hi NonText      guifg=#585858 guibg=#303030 gui=none   ctermfg=240 ctermbg=236
hi Folded       guifg=#d0d0d0 guibg=#404040 gui=italic ctermfg=252 ctermbg=237
hi LineNr       guifg=#585858 guibg=#121212 gui=none   ctermfg=240 ctermbg=233
hi VertSplit    guifg=#363636 guibg=#363636 gui=none   ctermfg=236 ctermbg=236
hi StatusLine   guifg=#d3d3d5 guibg=#363636 gui=italic ctermfg=253 ctermbg=236 cterm=italic
hi StatusLineNC guifg=#939395 guibg=#363636 gui=none   ctermfg=246 ctermbg=236
hi Visual       guifg=#faf4c6 guibg=#3c414c gui=none   ctermfg=254 ctermbg=4  
hi Search       guifg=#444444 guibg=#ffff00 gui=none   ctermfg=238 ctermbg=226

hi! link SpecialKey      NonText


"" Syntax highlighting
hi Todo         guifg=#000000 gui=italic ctermfg=0  
hi Comment      guifg=#9e9e9e gui=italic ctermfg=247
hi Statement    guifg=#9bcbdd gui=none   ctermfg=116
hi Type         guifg=#ffd700 gui=none   ctermfg=220
hi PreProc      guifg=#d7ffff gui=none   ctermfg=195
hi Special      guifg=#ffa0cc gui=none   ctermfg=213
hi String       guifg=#9dd700 gui=italic ctermfg=112
hi Constant     guifg=#9dd700 gui=none   ctermfg=112

hi! link Function       Normal
hi! link Character      String
hi! link Boolean        Constant
hi! link Number         Constant
hi! link Float          Constant
hi! link Identifier     Constant
hi! link Keyword        Statement
hi! link Label          Statement
hi! link Exception      Statement
hi! link Conditional    Statement
hi! link Operator       Statement


"" Specific colours for Vim >= 7.0
if version >= 700
    hi CursorLine   guibg=#202020 ctermbg=234
    hi SpellBad     guisp=#af0000 ctermfg=124

    hi! link CursorColumn    CursorLine
    hi! link SpellCap        SpellBad
    hi! link SpellLocal      SpellBad
    hi! link SpellRare       SpellBad
endif
