" Name:         festoon.vim
" Maintainer:   Carson Fire <carsonfire@gmail.com>
" Last Change:  2012-05-23
" Version:      1.2:    High contrast option added
" Version:      1.1:    More colors, better support for dark version
" Version:      1.0:    Initial upload (2011-12-20)

" Festoon is a dark and a light colorscheme in one. No special setup
" required, just set the background to dark or light, as desired. 

" Two functions are included to make switching backgrounds quick 'n easy.
" Sample mapping:
"
"       noremap <f2> <esc>:call BgToggle()<cr>
"       noremap <c-f2> <esc>:call ContrastToggle()<cr>


if !exists("FestoonContrast")
let g:FestoonContrast = "normal"
endif

if exists("syntax_on")
    exe 'hi clear'
    syntax reset
endif
let g:colors_name="festoon"

let s:Bisque0 = '#fff6f6'
let s:Bisque1 = '#f3ebea'
let s:Bisque2 = '#e2dad8'
let s:Bisque3 = '#cfc8c6'
let s:Bisque4 = '#a8a2a2'
let s:BlackBisque = '#323030'
let s:LtGrayMarble = '#cecece'
let s:DkGray = '#444444'
let s:Gray = '#777777'
let s:White = '#ffffff'
let s:Black = '#000000'
let s:AlmostBlack = '#222222'
let s:AlmostBlack2 = '#181818'
let s:AlmostAlmostBlack = '#333333'
let s:DkMaroon = '#703939'
let s:Maroon = '#884444'
let s:DarkFireOrange = '#b95e30'
let s:Maroon = '#800000'
let s:StrongYellow = '#ffe568'
let s:HunterGreen = '#326f62'
let s:Green = '#2e8b57'
let s:Pink = '#cba3a3'
let s:StrongPink = '#cb9898'
let s:DarkPink = '#8f7272'
let s:SantaRed = '#bb4747'
let s:Mustard = '#aea370'
let s:MuteBlue = '#73739f'
let s:Brown = '#7e6f68'
let s:RedBrown = '#804000'
let s:RubberStampBlue = '#326f9d'
let s:RubberStampSkyBlue = '#4190cd'
let s:SkyBlue = '#8fa4b5'
let s:TanGray = '#a19a9a'
let s:LtBrown = '#b9917d'
let s:TrippyBlue = '#6a5acd'
let s:TrippyLtBlue = '#8370ff'

let s:BlueGrad1 = '#5878da'
let s:BlueGrad2 = '#7e96da'
let s:BlueGrad3 = '#9daeda'
let s:RedGrad1 = '#9f5266'
let s:RedGrad2 = '#cf6b85'
let s:RedGrad3 = '#ff84a4'
let s:GreenGrad1 = '#296754'
let s:GreenGrad2 = '#328b66'
let s:GreenGrad3 = '#3aaf74'
let s:BrownGrad1 = '#735745'
let s:BrownGrad2 = '#a27a62'
let s:BrownGrad3 = '#d09d7e'

if &background == "dark"
    if g:FestoonContrast == "high"
        let s:Bg = s:Black
    else
        let s:Bg = s:BlackBisque
    endif
    let s:BgHi = s:AlmostBlack2
    let s:BgVyHi = s:Black
    let s:Fg = s:LtGrayMarble
    let s:FgLo = s:Gray
    let s:FgVyLo = s:DkGray
    let s:FgVyHi = s:Black
    let s:BgLo = s:DkGray
    let s:NiInv = s:AlmostAlmostBlack
    let s:Hdr0 = s:SantaRed
    let s:Ttl = s:SantaRed
    let s:String = s:DarkFireOrange
    let s:Warning = s:StrongPink
    let s:Search = s:StrongYellow
    let s:Match = s:DkGray
    let s:Character = s:GreenGrad3
    let s:Question = s:GreenGrad3
    let s:Err = s:White
    let s:Cursor = s:Bisque4
    let s:Constant = s:SantaRed
    let s:Number = s:Mustard
    let s:Identifier = s:BlueGrad2
    let s:Statement = s:BrownGrad3
    let s:PreProc = s:RedGrad2
    let s:Type = s:RubberStampSkyBlue
    let s:Function = s:SkyBlue
    let s:Comment = s:TanGray
    let s:Value = s:LtBrown
    let s:Link = s:TrippyLtBlue
    let s:Html = s:DarkPink
    let s:Spell = s:DarkPink

    let s:Grad1 = s:BlueGrad3
    let s:Grad2 = s:BlueGrad2
    let s:Grad3 = s:BlueGrad1
    let s:Grad4 = s:BrownGrad3
    let s:Grad5 = s:BrownGrad2
    let s:Grad6 = s:BrownGrad1
    let s:Grad7 = s:GreenGrad3
    let s:Grad8 = s:GreenGrad2
    let s:Grad9 = s:GreenGrad1
    let s:Grad10 = s:RedGrad3
    let s:Grad11 = s:RedGrad2
    let s:Grad12 = s:RedGrad1
else
    if g:FestoonContrast == "high"
        let s:Bg = s:White
    else
        let s:Bg = s:Bisque1
    endif
    let s:BgHi = s:Bisque0
    let s:BgVyHi = s:White
    let s:Fg = s:DkGray
    let s:FgLo = s:Gray
    let s:FgVyLo = s:Bisque4
    let s:FgVyHi = s:Black
    let s:BgLo = s:Bisque2
    let s:NiInv = s:Bisque3
    let s:Hdr0 = s:DkMaroon
    let s:Ttl = s:Maroon
    let s:String = s:DarkFireOrange
    let s:Warning = s:Maroon
    let s:Search = s:StrongYellow
    let s:Match = s:DkGray
    let s:Character = s:HunterGreen
    let s:Question = s:Green
    let s:Err = s:White
    let s:Cursor = s:Bisque4
    let s:Constant = s:SantaRed
    let s:Number = s:Mustard
    let s:Identifier = s:MuteBlue
    let s:Statement = s:Brown
    let s:PreProc = s:RedBrown
    let s:Type = s:RubberStampBlue
    let s:Function = s:SkyBlue
    let s:Comment = s:TanGray
    let s:Value = s:LtBrown
    let s:Link = s:TrippyBlue
    let s:Html = s:StrongPink
    let s:Spell = s:StrongPink

    let s:Grad1 = s:BrownGrad1
    let s:Grad2 = s:BrownGrad2
    let s:Grad3 = s:BrownGrad3
    let s:Grad4 = s:RedGrad1
    let s:Grad5 = s:RedGrad2
    let s:Grad6 = s:RedGrad3
    let s:Grad7 = s:GreenGrad1
    let s:Grad8 = s:GreenGrad2
    let s:Grad9 = s:GreenGrad3
    let s:Grad10 = s:BlueGrad1
    let s:Grad11 = s:BlueGrad2
    let s:Grad12 = s:BlueGrad3
endif

exe 'hi Normal gui=none guifg='.s:Fg.' guibg='.s:Bg
exe 'hi NonText gui=none guifg='.s:NiInv
exe 'hi Directory gui=none guifg='.s:Hdr0
exe 'hi Title gui=none guifg='.s:Ttl
exe 'hi CursorLine guibg='.s:BgHi
exe 'hi StatusLineNC gui=underline guifg='.s:FgLo.' guibg='.s:BgLo
exe 'hi StatusLine gui=underline guifg='.s:Fg.' guibg='.s:BgVyHi
exe 'hi VertSplit gui=bold,underline guifg='.s:FgVyLo.' guibg='.s:Bg
exe 'hi Conceal gui=none guifg='.s:Bg.' guibg='.s:Bg
exe 'hi Comment gui=none guifg='.s:Comment
exe 'hi Todo gui=none guifg='.s:BgVyHi.' guibg='.s:Fg
exe 'hi Folded gui=underline guifg='.s:FgLo.' guibg='.s:Bg
exe 'hi FoldColumn gui=none guifg='.s:BgHi.' guibg='.s:FgLo
exe 'hi TabLine gui=none guifg='.s:NiInv.' guibg='.s:FgLo
exe 'hi TabLineSel gui=none guifg='.s:Fg.' guibg='.s:Bg
exe 'hi TabLineFill gui=none guifg='.s:NiInv.' guibg='.s:Fg
exe 'hi textGrad1 gui=none guifg='.s:Grad1
exe 'hi textGrad2 gui=none guifg='.s:Grad2
exe 'hi textGrad3 gui=none guifg='.s:Grad3
exe 'hi textGrad4 gui=none guifg='.s:Grad4
exe 'hi textGrad5 gui=none guifg='.s:Grad5
exe 'hi textGrad6 gui=none guifg='.s:Grad6
exe 'hi textGrad7 gui=none guifg='.s:Grad7
exe 'hi textGrad8 gui=none guifg='.s:Grad8
exe 'hi textGrad9 gui=none guifg='.s:Grad9
exe 'hi textGrad10 gui=none guifg='.s:Grad10
exe 'hi textGrad11 gui=none guifg='.s:Grad11
exe 'hi textGrad12 gui=none guifg='.s:Grad12
exe 'hi SpecialKey gui=none guifg='.s:String
exe 'hi ErrorMsg gui=none guifg='.s:BgHi.' guibg='.s:Warning
exe 'hi IncSearch gui=none guifg='.s:FgVyHi.' guibg='.s:Search
exe 'hi Search gui=none guifg='.s:Match.' guibg='.s:Search
exe 'hi MoreMsg gui=none guifg='.s:String
exe 'hi ModeMsg gui=none guifg='.s:Character
exe 'hi LineNr gui=none guifg='.s:Search.' guibg='.s:Match
exe 'hi Question gui=none guifg='.s:Question
exe 'hi Visual gui=none guifg='.s:Err.' guibg='.s:Fg
exe 'hi VisualNOS gui=underline guifg='.s:Err.' guibg='.s:FgLo
exe 'hi WarningMsg gui=none guifg='.s:Err.' guibg='.s:Warning
exe 'hi WildMenu gui=none guifg='.s:Err.' guibg='.s:Warning
exe 'hi DiffAdd gui=underline guifg='.s:FgLo.' guibg='.s:Bg
exe 'hi DiffChange gui=none guifg='.s:Err.' guibg='.s:Cursor
exe 'hi DiffDelete gui=none guifg='.s:NiInv
exe 'hi DiffText gui=none guifg='.s:FgVyHi.' guibg='.s:FgVyHi
exe 'hi SignColumn gui=none guifg='.s:BgHi.' guibg='.s:FgLo
exe 'hi SpellBad gui=undercurl guisp='.s:Spell
exe 'hi SpellCap gui=undercurl guisp='.s:Function
exe 'hi SpellRare gui=undercurl guisp='.s:String
exe 'hi SpellLocal gui=undercurl guisp='.s:Question
exe 'hi Pmenu gui=none guifg='.s:Err.' guibg='.s:Cursor
exe 'hi PmenuSel gui=none guifg='.s:Cursor.' guibg='.s:Err
exe 'hi PmenuThumb gui=none guifg='.s:FgVyHi.' guibg='.s:FgVyHi
exe 'hi CursorColumn gui=none guifg='.s:BgHi.' guibg='.s:Warning
"exe 'hi ColorColumn'
exe 'hi Cursor gui=none guifg='.s:Err.' guibg='.s:Cursor
exe 'hi lCursor guifg=NONE guibg=Cyan'
exe 'hi MatchParen gui=none guibg='.s:Err
exe 'hi Constant gui=none guifg='.s:Constant
exe 'hi Special gui=none guifg='.s:Number
exe 'hi Identifier gui=none guifg='.s:Identifier
exe 'hi Statement gui=none guifg='.s:Statement
exe 'hi StatementUnderline gui=underline guifg='.s:Statement
exe 'hi StatementItalic gui=italic guifg='.s:Statement
exe 'hi StatementBold gui=bold guifg='.s:Statement
exe 'hi StatementBoldItalic gui=bold,italic guifg='.s:Statement
exe 'hi PreProc gui=none guifg='.s:PreProc
exe 'hi Type gui=none guifg='.s:Type
exe 'hi Underlined gui=underline guifg='.s:Fg
exe 'hi link Ignore Comment'
exe 'hi Error gui=none guifg='.s:Err.' guibg='.s:String
exe 'hi String gui=none guifg='.s:String
exe 'hi Character gui=none guifg='.s:Character
exe 'hi Number gui=none guifg='.s:Number
exe 'hi Boolean gui=none guifg='.s:Warning
exe 'hi Float gui=none guifg='.s:Type
exe 'hi Function gui=none guifg='.s:Function
exe 'hi Conditional gui=none guifg='.s:Character
exe 'hi Repeat gui=none guifg='.s:Number
exe 'hi link Label String'
exe 'hi Operator gui=none guifg='.s:Type
exe 'hi Keyword gui=none guifg='.s:Type
exe 'hi Exception gui=none guifg='.s:Warning
exe 'hi Include gui=none guifg='.s:Type
exe 'hi link Define String '
exe 'hi Macro gui=none guifg='.s:Character
exe 'hi Precondit gui=none guifg='.s:Number
exe 'hi link StorageClass String'
exe 'hi link Structure String'
exe 'hi Typedef gui=none guifg='.s:Character
exe 'hi Tag gui=none guifg='.s:Type
exe 'hi SpecialChar gui=none guifg='.s:Character
exe 'hi Delimiter gui=none guifg='.s:Statement
exe 'hi SpecialComment gui=none guifg='.s:Number
exe 'hi Debug gui=none guifg='.s:Question
exe 'hi CursorIM gui=none guifg='.s:Spell.' guibg='.s:Spell
exe 'hi browseSuffixes gui=none guifg='.s:Type
exe 'hi link treeOpenable Precondit'
exe 'hi link treeHelpTitle Normal'
exe 'hi link treeFile Tag'
exe 'hi link treeExecFile String'
exe 'hi link treeLink Comment'
exe 'hi link treeRO Statement'
exe 'hi link netrwPlain Tag'
exe 'hi link netrwComment Normal'
exe 'hi link netrwExe String'
exe 'hi link netrwSymLink Comment'
exe 'hi link netrwSpecial Statement'
exe 'hi link netrwTime Number'
exe 'hi link netrwTimeSep Number'
exe 'hi link netrwDateSep Statement'
exe 'hi link netrwSizeDate Statement'
exe 'hi link VimwikiHeader1 htmlH1'
exe 'hi link VimwikiHeader2 htmlH2'
exe 'hi link VimwikiHeader3 htmlH3'
exe 'hi link VimwikiHeader4 htmlH4'
exe 'hi link VimwikiHeader5 htmlH5'
exe 'hi link VimwikiHeader6 htmlH6'
exe 'hi VimwikiEmoticons guifg='.s:Match.' guibg='.s:Search
exe 'hi link VimwikiLink htmlLink'
exe 'hi link VimwikiLinkT htmlLink'
exe 'hi link VimwikiHeaderChar Comment'
exe 'hi VimwikiCellSeparator gui=inverse'
exe 'hi def link vikiHyperLink htmlLink'
"exe 'hi link vikiHeading'
exe 'hi link vikiList Operator'
"exe 'hi link vikiTableHead'
"exe 'hi link vikiTableRow'
"exe 'hi link vikiSymbols'
"exe 'hi link vikiMarkers'
exe 'hi link vikiAnchor htmlString '
exe 'hi link vikiString String'
exe 'hi vikiBold gui=bold'
exe 'hi vikiItalic gui=italic'
exe 'hi vikiUnderline gui=underline'
exe 'hi vikiTypewriter guifg='.s:Statement
exe 'hi link vikiCommand Comment'
exe 'hi link markdownValid Normal'
" exe 'hi link markdownLineStart'
exe 'hi link markdownH1 htmlH1 '
exe 'hi link markdownH2 htmlH2'
exe 'hi link markdownH3 htmlH3 '
exe 'hi link markdownH4 htmlH4'
exe 'hi link markdownH5 htmlH5'
exe 'hi link markdownH6 htmlH6'
exe 'hi link markdownBlockquote String'
exe 'hi link markdownListMarker Operator'
exe 'hi link markdownOrderedListMarker markdownListMarker'
exe 'hi link markdownCodeBlock markdownCode'
exe 'hi markdownLineBreak guibg='.s:Fg
exe 'hi link markdownLinkText htmlLink'
exe 'hi markdownCode guifg='.s:Statement
exe 'hi markdownEscape guifg='.s:Type
exe 'hi link markdownHeadingRule Comment'
exe 'hi link markdownHeadingDelimiter Comment'
exe 'hi link markdownLinkDelimiter Comment'
exe 'hi link markdownUrl htmlString'
"exe 'hi markdownIdDeclaration'
exe 'hi link markdownUrlTitle Label'
exe 'hi link markdownUrlDelimiter Comment'
exe 'hi link markdownUrlTitleDelimiter Comment'
exe 'hi link markdownRule Comment'
exe 'hi link markdownLinkTextDelimiter Comment'
"exe 'hi markdownLink'
"exe 'hi markdownId'
"exe 'hi markdownIdDelimiter'
exe 'hi link markdownAutomaticLink htmlLink'
exe 'hi markdownBoldItalic gui=bold,italic'
"exe 'hi markdownCodeDelimiter'
exe 'hi markdownBold gui=bold'
exe 'hi markdownItalic gui=italic'
exe 'hi link wikiH1 htmlH1 '
exe 'hi link wikiH2 htmlH2'
exe 'hi link wikiH3 htmlH3 '
exe 'hi link wikiH4 htmlH4'
exe 'hi link wikiH5 htmlH5'
exe 'hi link wikiH6 htmlH6'
exe 'hi link rest1 htmlH1 '
exe 'hi link rest2 htmlH2'
exe 'hi link rest3 htmlH3 '
exe 'hi link rest4 htmlH4'
exe 'hi link rest5 htmlH5'
exe 'hi link rest6 htmlH6'
exe 'hi link txtHeader htmlH1 '
exe 'hi link txtHeader2 htmlH2'
exe 'hi link txtHeader3 htmlH3 '
exe 'hi link pandocBlockQuote markdownBlockquote'
exe 'hi link pandocCodeBlock markdownCode'
exe 'hi link pandocDelimitedCodeBlock markdownCode'
exe 'hi link pandocDelimitedCodeBlockLanguage markdownCode'
exe 'hi link pandocCodePre markdownCode'
exe 'hi link pandocLinkArea Comment'
exe 'hi link pandocLinkText markdownLinkText'
exe 'hi link pandocLinkURL	htmlLink'
exe 'hi link pandocLinkTextRef markdownLinkText'
exe 'hi link pandocLinkTitle markdownLinkText'
exe 'hi link pandocAutomaticLink htmlLink'
exe 'hi link pandocHRule	Comment'
exe 'hi link pandocPCite markdownLinkText'
exe 'hi htmlBoldUnderline gui=bold,underline'
exe 'hi htmlBoldItalic gui=bold,italic'
exe 'hi htmlBold gui=bold'
exe 'hi htmlBoldUnderlineItalic gui=bold,underline,italic'
exe 'hi link htmlBoldItalicUnderline htmlBoldUnderlineItalic '
exe 'hi link htmlUnderlineBold htmlBoldUnderline'
exe 'hi htmlUnderlineItalic gui=underline,italic'
exe 'hi htmlUnderline gui=underline'
exe 'hi link htmlUnderlineBoldItalic htmlBoldUnderlineItalic'
exe 'hi link htmlUnderlineItalicBold htmlBoldUnderlineItalic'
exe 'hi link htmlItalicBold htmlBoldItalic'
exe 'hi link htmlItalicUnderline htmlUnderlineItalic'
exe 'hi htmlItalic gui=italic'
exe 'hi link htmlItalicBoldUnderline htmlBoldUnderlineItalic'
exe 'hi link htmlItalicUnderlineBold htmlBoldUnderlineItalic'
exe 'hi link htmlTitle Title'
exe 'hi link htmlCssStyleComment Comment'
exe 'hi link htmlScriptTag htmlTag'
exe 'hi link htmlEventSQ htmlEvent'
exe 'hi link htmlEventDq htmlEvent'
exe 'hi link htmlStyleArg htmlString'
"exe 'hi htmlHighlight'
"exe 'hi htmlHightlightSkip'
exe 'hi link htmlSpecial Special'
exe 'hi htmlStatement guifg='.s:Html
exe 'hi htmlEndTag guifg='.s:Html
exe 'hi htmlTag guifg='.s:Html
exe 'hi htmlTagN guifg='.s:Html
exe 'hi htmlTagName guifg='.s:Html
exe 'hi htmlSpecialTagName guifg='.s:Html
exe 'hi htmlArg gui=none guifg='.s:Function
exe 'hi htmlString gui=none guifg='.s:Statement
exe 'hi htmlValue gui=none guifg='.s:Value
exe 'hi htmlSpecialChar guifg='.s:Number
exe 'hi htmlLink guifg='.s:Link.' gui=none'
exe 'hi htmlH1 guifg='.s:String.' gui=none'
exe 'hi htmlH2 guifg='.s:String.' gui=italic'
exe 'hi htmlH3 guifg='.s:Type.' gui=none'
exe 'hi htmlH4 guifg='.s:Type.' gui=italic'
exe 'hi htmlH5 guifg='.s:PreProc.' gui=none'
exe 'hi htmlH6 guifg='.s:PreProc.' gui=italic'
exe 'hi link xmlTagName htmlTagName'
exe 'hi link xmlTag htmlTag'
exe 'hi link xmlEndTag htmlTag'
exe 'hi link phpFunctions Function'
exe 'hi link phpOperator Operator'
exe 'hi link phpStructure Structure'
exe 'hi link phpSpecial Special'
exe 'hi link twitterLink htmlLink'
exe 'hi link twitterTime Number'
exe 'hi link textEmotion textEmoticons'
exe 'hi textEmoticons guifg='.s:Match.' guibg='.s:Search
exe 'hi link textSection Directory'
exe 'hi link textDialogue Tag'
exe 'hi link textAction Special'
exe 'hi link textLineEnd Comment'
exe 'hi link textKoppa String'
exe 'hi textBoldUnderline gui=bold,underline'
exe 'hi textBoldItalic gui=bold,italic'
exe 'hi textBold gui=bold'
exe 'hi textBoldUnderlineItalic gui=bold,underline,italic'
exe 'hi link textBoldItalicUnderline textBoldUnderlineItalic '
exe 'hi link textUnderlineBold textBoldUnderline'
exe 'hi textUnderlineItalic gui=underline,italic'
exe 'hi textUnderline gui=underline'
exe 'hi link textUnderlineBoldItalic textBoldUnderlineItalic'
exe 'hi link textUnderlineItalicBold textBoldUnderlineItalic'
exe 'hi link textItalicBold textBoldItalic'
exe 'hi link textItalicUnderline textUnderlineItalic'
exe 'hi textItalic gui=italic'
if !exists("*BgToggle")
    function BgToggle()
        if &background == "light"
            set background=dark
        else
            set background=light
        endif
    endfunction
endif
if !exists("*FestConToggle")
    function FestConToggle()
        if g:FestoonContrast == "high"
            let g:FestoonContrast = "normal"
        else
            let g:FestoonContrast = "high"
        endif
        colo festoon
    endfunction
endif
