" Vim color file
" Maintainer:	Andrew Lyon <orthecreedence@gmail.com>
" Last Change:	2012-03-21 06:01:00 PST
" Version:	2.1

" Note that this color scheme is loosely based off of desert.vim (Hans Fugal
" <hans@fugal.net>) mixed with some of slate.vim (Ralph Amissah
" <ralph@amissah.com>) but with much of my own modification.

set background=dark
if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
	syntax reset
    endif
endif
let g:colors_name="void"

hi Normal	guifg=#e0e0e0 guibg=grey15

" highlight groups
hi Cursor	guibg=khaki guifg=slategrey
"hi CursorIM
"hi Directory
"hi DiffAdd
"hi DiffChange
"hi DiffDelete
"hi DiffText
"hi ErrorMsg
hi VertSplit	guibg=black guifg=black gui=none
hi Folded	guibg=grey30 guifg=gold
hi FoldColumn	guibg=grey30 guifg=tan
hi IncSearch	guifg=slategrey guibg=khaki
"hi LineNr
hi ModeMsg	guifg=goldenrod
hi MoreMsg	guifg=SeaGreen
hi NonText	guifg=LightBlue guibg=grey30
hi Question	guifg=springgreen
hi Search	guibg=peru guifg=wheat
hi SpecialKey	guifg=yellowgreen
hi StatusLine	guibg=black guifg=#cccccc gui=none
hi StatusLineNC	guibg=black guifg=grey40 gui=none
hi Title	guifg=indianred
hi Visual	gui=none guifg=khaki guibg=olivedrab
"hi VisualNOS
hi WarningMsg	guifg=salmon
"hi WildMenu
"hi Menu
"hi Scrollbar
"hi Tooltip

" syntax highlighting groups
hi Comment	guifg=grey50 ctermfg=darkcyan
hi Constant	guifg=#e09085 ctermfg=brown
hi Identifier	guifg=#d0d0b0
hi Statement	guifg=#ccaa88 gui=bold cterm=bold term=bold
"hi Statement	guifg=darkkhaki
hi PreProc	guifg=#c8e0b0
hi Type		guifg=#99cccc term=NONE cterm=NONE gui=NONE
hi Special	guifg=#bbccee cterm=bold term=bold
hi Operator guifg=navajowhite cterm=NONE
"hi Underlined
hi Ignore	guifg=grey40
"hi Error
hi Todo		guifg=orangered guibg=yellow2
hi Todo		guifg=orange guibg=gray40

" Fuf/menu stuff
hi Pmenu		guifg=#aadddd guibg=#333333
hi PmenuSel		guifg=#ddeeee guibg=#335533

" color terminal definitions
hi SpecialKey	ctermfg=darkgreen
hi NonText	guibg=grey15 cterm=bold ctermfg=darkblue
hi Directory	ctermfg=brown  guifg=#ddbb66
hi ErrorMsg	cterm=bold ctermfg=7 ctermbg=1
hi IncSearch	cterm=NONE ctermfg=yellow ctermbg=green
hi Search	cterm=NONE ctermfg=grey ctermbg=blue
hi MoreMsg	ctermfg=darkgreen
hi ModeMsg	cterm=NONE ctermfg=brown
hi LineNr guifg=grey50 ctermfg=3
hi Question	ctermfg=green
hi StatusLine	cterm=bold,reverse
hi StatusLineNC cterm=reverse
hi VertSplit	cterm=reverse
hi Title	ctermfg=5
hi Visual	cterm=reverse
hi VisualNOS	cterm=bold,underline
hi WarningMsg	ctermfg=1
hi WildMenu	ctermfg=0 ctermbg=3
hi Folded	ctermfg=darkgrey ctermbg=NONE
hi FoldColumn	ctermfg=darkgrey ctermbg=NONE
hi DiffAdd	ctermbg=4
hi DiffChange	ctermbg=5
hi DiffDelete	cterm=bold ctermfg=4 ctermbg=6
hi DiffText	cterm=bold ctermbg=1
hi Special	ctermfg=5
hi Identifier	ctermfg=6
hi Statement	ctermfg=3
hi PreProc	ctermfg=5
hi Type		ctermfg=2
hi Underlined	cterm=underline ctermfg=5
hi Ignore	cterm=bold ctermfg=7
hi Ignore	ctermfg=darkgrey
hi Error	cterm=bold ctermfg=7 ctermbg=1

" Filetype specifics"{{{
	" Special for Ruby"{{{
	hi  rubyRegexp                 guifg=#af875f guibg=NONE gui=NONE ctermfg=137 ctermbg=NONE cterm=NONE
	hi  rubyRegexpDelimiter        guifg=#ff8700 guibg=NONE gui=NONE ctermfg=208 ctermbg=NONE cterm=NONE
	hi  rubyEscape                 guifg=#ffffff guibg=NONE gui=NONE ctermfg=15  ctermbg=NONE cterm=NONE
	hi  rubyInterpolationDelimiter guifg=#00afaf guibg=NONE gui=NONE ctermfg=37  ctermbg=NONE cterm=NONE
	hi  rubyControl                guifg=#5f87d7 guibg=NONE gui=NONE ctermfg=68  ctermbg=NONE cterm=NONE
	"hi rubyGlobalVariable         guifg=#FFCCFF guibg=NONE gui=NONE ctermfg=225 ctermbg=NONE cterm=NONE
	hi  rubyStringDelimiter        guifg=#5f875f guibg=NONE gui=NONE ctermfg=65 ctermbg=NONE cterm=NONE
	"rubyInclude
	"rubySharpBang
	"rubyAccess
	"rubyPredefinedVariable
	"rubyBoolean
	"rubyClassVariable
	"rubyBeginEnd
	"rubyRepeatModifier
	"hi link rubyArrayDelimiter    Special  " [ , , ]
	"rubyCurlyBlock  { , , }
	hi link rubyClass             Keyword
	hi link rubyModule            Keyword
	hi link rubyKeyword           Keyword
	hi link rubyOperator          Operator
	hi link rubyIdentifier        Identifier
	hi link rubyInstanceVariable  Identifier
	hi link rubyGlobalVariable    Identifier
	hi link rubyClassVariable     Identifier
	hi link rubyConstant          Type
	"}}}
	" Special for HTML"{{{
	hi htmlH1        guifg=#00afd7 guibg=NONE gui=UNDERLINE ctermfg=38  ctermbg=NONE cterm=BOLD
	hi htmlLink      guifg=#d7d75f guibg=NONE gui=NONE      ctermfg=185 ctermbg=NONE cterm=NONE
	hi htmlString    guifg=#87875f guibg=NONE gui=NONE      ctermfg=101 ctermbg=NONE cterm=NONE
	hi htmlTagName   guifg=#d7afd7 guibg=NONE gui=NONE      ctermfg=182 ctermbg=NONE cterm=NONE
	hi link htmlTag         Keyword
	hi link htmlEndTag      Identifier
	hi link htmlH2 htmlH1
	hi link htmlH3 htmlH1
	hi link htmlH4 htmlH1
	"}}}
	" Special for XML"{{{
	hi link xmlTag          Keyword
	hi link xmlTagName      htmlTagName
	hi link xmlEndTag       Identifier
	"}}}
	" Special for CSS"{{{
	hi cssTagName guifg=#70a8dd gui=BOLD  ctermfg=74 cterm=BOLD
	hi cssBoxProp guifg=#d0af76  gui=NONE  ctermfg=180 gui=NONE
	hi link cssColorProp cssBoxProp
	hi link cssFontProp cssBoxProp
	hi link cssTextProp cssBoxProp
	hi cssPseudoClassId guifg=#9ccfdd gui=italic ctermfg=152 cterm=NONE
	hi cssIdentifier    guifg=#3fc493 gui=italic ctermfg=115 cterm=NONE
	"}}}
	" Special for Markdown"{{{
	hi markdownUrl       guifg=#af8787 guibg=NONE gui=NONE      ctermfg=138 ctermbg=NONE cterm=NONE
	hi markdownCode      guibg=#3a3a3a guifg=#a7bee4 gui=BOLD ctermbg=237 ctermfg=152 cterm=BOLD
	hi markdownCodeBlock guifg=#c5b1e4 ctermfg=182
	hi markdownLinkText  guifg=#0087af gui=UNDERLINE ctermfg=31

	hi markdownH1        guifg=#d75f00 guibg=NONE gui=BOLD,ITALIC,UNDERLINE ctermfg=166  ctermbg=NONE cterm=BOLD
	hi markdownH2        guifg=#d75f87 guibg=NONE gui=BOLD,UNDERLINE ctermfg=168  ctermbg=NONE cterm=BOLD
	hi markdownH3        guifg=#d78787 guibg=NONE gui=ITALIC,UNDERLINE ctermfg=174  ctermbg=NONE cterm=BOLD

	hi markdownBold    guifg=#ffd75f guibg=NONE gui=BOLD      ctermfg=221 ctermbg=NONE cterm=BOLD
	hi markdownItalic    guifg=#afff87 guibg=NONE gui=ITALIC      ctermfg=156 ctermbg=NONE cterm=NONE

	hi markdownOrderedListMarker  guifg=#5fff00  gui=BOLD ctermfg=82 cterm=BOLD
	hi markdownListMarker  guifg=#ffff00  gui=BOLD ctermfg=226 cterm=BOLD

	hi markdownBlockQuote   guifg=#00ffff gui=BOLD ctermfg=14 cterm=BOLD
	"}}}
	" Special for Javascript"{{{
	hi JavaScriptStrings          guifg=#26b3ac guibg=NONE gui=ITALIC ctermfg=45  ctermbg=NONE  cterm=NONE
	hi link javaScriptNumber      Number
	hi link javaScript  Normal
	hi link javaScriptBrowserObjects PreProc
	hi link javaScriptDOMObjects     PreProc
	"}}}
	" Special for Python"{{{
	"hi  link pythonEscape         Keyword
	hi pythonBuiltin          guifg=#50bf95 guibg=NONE  gui=ITALIC ctermfg=42  cterm=UNDERLINE
	"}}}
	" Special for PHP"{{{
	hi phpDefine  guifg=#ffc795    gui=BOLD ctermfg=209 cterm=BOLD
	hi phpStringSingle  guifg=#e8e8d3 guibg=NONE gui=NONE ctermfg=250 ctermbg=NONE  cterm=NONE
	hi link phpStringDouble Ignore
	"}}}
	" Special for Java"{{{
	" hi link javaClassDecl    Type
	hi link javaScopeDecl         Identifier
	hi link javaCommentTitle      javaDocSeeTag
	hi link javaDocTags           javaDocSeeTag
	hi link javaDocParam          javaDocSeeTag
	hi link javaDocSeeTagParam    javaDocSeeTag

	hi  javaDocSeeTag guifg=#CCCCCC guibg=NONE gui=NONE ctermfg=252 ctermbg=NONE cterm=NONE
	"hi javaClassDecl guifg=#CCFFCC guibg=NONE gui=NONE ctermfg=194 ctermbg=NONE cterm=NONE
	"}}}
"}}}
