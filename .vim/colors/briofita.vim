" Briofita colorscheme header {{{1
" =============================================================================
" Name:        Briofita
" Scriptname:  briofita.vim
" Description: Another oddly named dark background colorscheme.
"              As 'Briofita' is akin to 'Bryophyta', so should it be pronounced.
" Author:      Sergio Nobre <sergio.o.nobre@gmail.com>
" License:     Vim License
" Version:     1.5.0
" Last Change: Wednesday, August 1st, 2012
" Inspiration: Tweaks on the Moss vimscript to fit personal preferences are in
"              the origins of this colorscheme. (Moss, by Chunlin Li, 
"              http://www.vim.org/scripts/script.php?script_id=2779, is a 'dark 
"              scheme consisting primarily of green & blue'). Additionally, 
"              I adapted the color dictionary used in Distinguished, a script 
"              by Kim Silkebækken. Besides these, several other favourite schemes 
"              have influenced either the design or the coding style.
" Usage:       For details on usage refer to the Briofita WEB PAGE at Vim online:
"              http://www.vim.org/scripts/script.php?script_id=4136
" Feedback:    Any feedback is welcome! In e-mails, please prepend [VIM] in the 
"              subject title; otherwise it may be treated as spam. 
" =============================================================================

" General Notes:                                                         {{{1
" Versions:                                                              {{{2
" Version 1.5.0 - Improved color highlights of a few elements.           {{{3
"                 Added an informative function, g:BriofitaVersion(*).
"                 Has a new function g:BriofitaNoDistraction(*) and a new parameter 
"                 variable 't:Briofita_no_distraction_mode' that triggers 
"                 distractionless mode; and ColorColumn option now accepts 3, 
"                 meaning 'do not set usual ColorColumn highlight' for that mode. 
"                 All options were normalized so that defaults are now zero. Parameter 
"                 variables are reset to default value if outside the proper range.
" Version 1.4   - Bug fix on option for CursorLineNr.                     {{{3
" Version 1.3   - Improved defaults logic.                                {{{3
" Version 1.2   - Improved option *choice_for_colorcolumn.                {{{3
" Version 1.1   - Bug fix on option *choice_for_cursorline.               {{{3
" First Release:                                                          {{{2
" Version 1.0   - Still a work in progress, with the following features,
"   constraints or limitations:
"       * it was designed only for Vim GUI (gvim); terminals are not supported;
"       * it is intended for use in Vim versions >= 7.3; and it was tested with gVim 7.3 
"         under Precise Pangolin Ubuntu Linux;
"       * its default background is in a shaded dark green color;
"       * by default, it displays most of the text in nuances of green, blue,
"         purple or violet; although the style is not uniform among different syntaxes;
"       * for contrasting, it uses red or reverse highlight in a few 
"         syntactic items of each filetype; it has a red ICursor set via 'guicursor' 
"         option; and it uses orange to highlight Python indentation erros.
"       * a few highlights may be changed via global options.
" ===============================================================================
"
" Setup: check Vim version, set color name, etc.                          {{{1

let this_color = "briofita"

if (!has('gui_running')) || (!v:version >= 703)
    echoerr "Colorscheme ".this_color." was designed only for Vim versions >= 7.3.0 in GUI mode." 
    finish
endif
let s:briofitaVersion= "1.5.0"
set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = this_color

let save_cpo = &cpo
set cpo&vim

" Cursorcolors Dictionary: cursor colors selectable via global variable option {{{1
" related to the var for 'choice' of cursorline; see usage at the end of this source
if !exists("s:Briofita_cursorcolors")
        let s:Briofita_cursorcolors={
            \   0        : "#333399",
            \   1        : "#3A5022",
            \   2        : "#880c0e",
            \   3        : "Navy",
            \   4        : "DarkMagenta",
            \   5        : "SaddleBrown",
            \   6        : "#333399", 
            \   7        : "#3A5022",
            \   8        : "Black",
            \   9        : "" 
            \ }
endif
" Global Variables Initialization: check, or set their values            {{{1
" FIXME simplify/optimize these IFs; are max values tests needed at this point? 
let s:maxx = len(s:Briofita_cursorcolors)-1 " maximun key
if exists("t:Briofita_no_distraction_mode") 
    " NOTE Since v1.5.0 this variable commands non-distractionless mode.
    " NOTE For the NORMAL behavior to take place this t: variable should NOT exist!
    " NOTE So, if you use this mode in a tabpage and later use the normal mode on it
    " NOTE remember to DELETE this t:var! ie issue an UNLET command on it!
    " NOTE But it is more practical to close! that tab and work in a new one!
    if t:Briofita_no_distraction_mode < 0
        let t:Briofita_no_distraction_mode = 0
    elseif t:Briofita_no_distraction_mode > 1
        let t:Briofita_no_distraction_mode = 0
    endif
endif
if !exists("g:Briofita_choice_for_cursorline") 
    if !exists("t:Briofita_choice_for_cursorline")
        let t:Briofita_choice_for_cursorline = 0
    endif
else
    if g:Briofita_choice_for_cursorline >= s:maxx
        let g:Briofita_choice_for_cursorline = 0 " enable rotation
    endif
endif
if !exists("t:Briofita_choice_for_cursorline") 
    if exists("g:Briofita_choice_for_cursorline") 
        if g:Briofita_choice_for_cursorline < 0
            let t:Briofita_choice_for_cursorline = 0
        else
            let t:Briofita_choice_for_cursorline = g:Briofita_choice_for_cursorline
        endif
    else
        let t:Briofita_choice_for_cursorline = 0
    endif
endif
if exists("g:Briofita_choice_for_cursorline") 
    if g:Briofita_choice_for_cursorline >= 0
        if g:Briofita_choice_for_cursorline != t:Briofita_choice_for_cursorline
            let t:Briofita_choice_for_cursorline = g:Briofita_choice_for_cursorline
        endif
    endif
endif
if (t:Briofita_choice_for_cursorline < 0)
    let t:Briofita_choice_for_cursorline = 0
elseif (t:Briofita_choice_for_cursorline >= s:maxx) " the last entry is just a sentinel
    let t:Briofita_choice_for_cursorline = 0
endif
if !exists("g:Briofita_choice_for_colorcolumn")
    let g:Briofita_choice_for_colorcolumn = 0
endif
if !exists("g:Briofita_choice_for_search")
    let g:Briofita_choice_for_search = 0
endif
if !exists("g:Briofita_choice_for_normalcolor")
    let g:Briofita_choice_for_normalcolor = 0
endif
if !exists("g:Briofita_choice_for_cursorlinenr")
    let g:Briofita_choice_for_cursorlinenr = 0
endif

" BriofitaVersion Function: returns info string with version # and some parms.  {{{1
function! g:BriofitaVersion() 
    " if Briofita is not the current colorscheme: just return name and version
    let info  = "'Briofita v".s:briofitaVersion
    if g:colors_name=="briofita"
        " if it is the current colorscheme: show parameter variables
        let info .= " *ColorColumn=". g:Briofita_choice_for_colorcolumn
        let info .= " *CursorLineNr=".g:Briofita_choice_for_cursorlinenr
        let info .= " *Normal=".      g:Briofita_choice_for_normalcolor
        let info .= " *Search=".      g:Briofita_choice_for_search
        let info .= " *Search=".      g:Briofita_choice_for_search
        let culglb = 1
        if exists("g:Briofita_choice_for_cursorline")
            if g:Briofita_choice_for_cursorline < 0
                let culglb = 0 " not a global setting; but tabpage-local
            endif
        endif
        if culglb
            let info .= " *CursorLine="
        else
            let info .= " tabpg(".printf("%03d",tabpagenr()).")::CursorLine="
        endif
        let info .= t:Briofita_choice_for_cursorline
        if exists("t:Briofita_no_distraction_mode")
            let info .= " tabpg(".printf("%03d",tabpagenr()).")::NoDistractionMode"
            let info .= printf("(%d)",t:Briofita_no_distraction_mode)
        else
            let info .= " tabpg(".printf("%03d",tabpagenr()).")::NormalMode"
        endif
    else 
        let info .= " (non-current color)"
    endif
    let info .= "'"
    return(info)
endfunction

" BriofitaNoDistraction Function: a distractionless editing mode         {{{1
function! g:BriofitaNoDistraction(style) 
    " NOTE This option has been designed to support distractionless editing
    " NOTE and it internally overrides a few other options.
    " NOTE Ideally this mode is to be used when you have installed some 
    " NOTE distractionless editing PLUGIN; because here we ONLY set highlights 
    " NOTE while a PLUGIN will have other, complementary, settings.
    if a:style == 0
        " Briofita normal background and foreground
        let nodstBG1 = "#062926"
        let nodstFG1 = "#062926"
        let normFG   = "#C6B6FE"
    else 
        " a typical distractionless editing background
        let nodstBG1 = "Black"
        let nodstFG1 = "Black"
        " blue foreground
        let normFG   = "#49bef3"
    endif 
    execute "highlight NonText     gui=NONE guifg=".nodstFG1." guibg=".nodstBG1
    execute "highlight VertSplit   gui=NONE guifg=".nodstFG1." guibg=".nodstBG1
    execute "highlight FoldColumn                              guibg=".nodstBG1
    execute "highlight signColumn                              guibg=".nodstBG1
    "execute "hi ight Color Column gui=NONE guifg=PaleGreen3   guibg=".nodstBG1
    execute "highlight ColorColumn gui=NONE guifg=NONE guibg=NONE"
    execute 'let usrFG = "#401340"'
    execute 'let usrBG = "#401340"'
    execute "highlight User1   gui=NONE   guifg=".usrFG." guibg=".usrBG
    execute "highlight User2   gui=NONE   guifg=".usrFG." guibg=".usrBG
    execute "highlight User3   gui=NONE   guifg=".usrFG." guibg=".usrBG
    execute "highlight User4   gui=NONE   guifg=".usrFG." guibg=".usrBG
    execute "highlight User5   gui=NONE   guifg=".usrFG." guibg=".usrBG
    execute "highlight User6   gui=NONE   guifg=".usrFG." guibg=".usrBG
    execute "highlight User7   gui=NONE   guifg=".usrFG." guibg=".usrBG
    execute "highlight User8   gui=NONE   guifg=".usrFG." guibg=".usrBG
    execute "highlight User9   gui=NONE   guifg=".usrFG." guibg=".usrBG
    execute 'let statFG = "#401340"'
    execute 'let statBG = "#401340"'
    execute "highlight StatusLine   gui=NONE   guifg=".statFG." guibg=".statBG
    execute "highlight StatusLineNC gui=NONE   guifg=".statFG." guibg=".statBG
    execute "highlight Normal gui=NONE   guifg=".normFG." guibg=".nodstBG1
    execute 'let culBG = "'.s:Briofita_cursorcolors[2].'"'  
    execute "highlight CursorLine   gui=bold guifg=NONE guibg=".culBG
    execute "highlight CursorColumn gui=NONE guifg=NONE guibg=".culBG
    " global var below is a 'request' to not later change ColorColumn
    let g:Briofita_choice_for_colorcolumn=3
    unlet normFG culBG statFG statBG usrFG usrBG nodstBG1 nodstFG1
    return
endfunction

" ColorDictParser Function: used to create the colors dictionary         {{{1
function! s:ColorDictParser(color_dict) " Color dictionary parser 
    " NOTE This is a modified version of the corresponding function of 
    " NOTE vimscript # 3529 (Distinguished colorscheme) developed by Kim Silkebækken.
    for [group, group_colors] in items(a:color_dict)
			exec 'highlight ' . group
				\ . ( ! empty(group_colors[0]) ? ' guifg=' . group_colors[0]: '')
				\ . ( ! empty(group_colors[1]) ? ' guibg=' . group_colors[1]: '')
				\ . ( ! empty(group_colors[2]) ? ' gui='   . group_colors[2]: '')
    endfor
endfunction
"
" Color Dictionary Initialization: defines most of the colors used in the colorscheme  {{{1
"       |-------------------|-----------|-------------|-----------------|
"       | Highlight group   |Foreground |Background   |   Attributes    |
"       |-------------------|-----------|-------------|-----------------|
call s:ColorDictParser({ 
    \   "adaAssignment"                         : [ "Red", "",  ""],
    \   "adaAttribute"                          : [ "DodgerBlue3", "",  "italic"],
    \   "adaSpecial"                            : [ "Red", "",  ""],
    \   "asciidocAdmonition"                    : ["Wheat2", "VioletRed4",  "underline,italic"],
    \   "asciidocAnchorMacro"                   : [ "DodgerBlue2", "",  ""],
    \   "asciidocAttributeEntry"                : [ "#f8ed97", "",  ""],
    \   "asciidocAttributeList"                 : ["LightSteelBlue", "",  ""],
    \   "asciidocAttributeMacro"                : [ "DodgerBlue2", "",  ""],
    \   "asciidocAttributeRef"                  : ["SeaGreen2", "#573D8C", ""],
    \   "asciidocBackslash"                     : [ "#88CB35", "",  ""],
    \   "asciidocBlockTitle"                    : [ "LightSteelBlue","rosybrown4",  "bold,italic"],
    \   "asciidocCallout"                       : [ "SeaGreen2", "",  "NONE"],
    \   "asciidocCommentBlock"                  : [ "#009F6F", "", "bold,italic"],
    \   "asciidocCommentLine"                   : [ "#8B8B8B", "",  "italic"],
    \   "asciidocDoubleDollarPassthrough"       : [ "DodgerBlue2", "",  ""],
    \   "asciidocEmail"                         : [ "DodgerBlue2", "",  ""],
    \   "asciidocEntityRef"                     : [ "SeaGreen2", "",  "NONE"],
    \   "asciidocExampleBlockDelimiter"         : [ "#779DB2", "",  ""],
    \   "asciidocFilterBlock"                   : [ "DeepSkyBlue2", "",  ""],
    \   "asciidocHLabel"                        : [ "SeaGreen2", "",  "NONE"],
    \   "asciidocHyphenInterpolation"           : ["#9FE846", "#573D8C", ""],
    \   "asciidocIdMarker"                      : [ "SpringGreen2", "",  ""],
    \   "asciidocIndexTerm"                     : [ "DodgerBlue2", "",  ""],
    \   "asciidocLineBreak"                     : [ "Red", "",  ""],
    \   "asciidocList"                          : [ "#99ad6a", "",  ""],
    \   "asciidocListBlockDelimiter"            : [ "#779DB2", "",  ""],
    \   "asciidocListBullet"                    : [ "SpringGreen2", "",  ""],
    \   "asciidocListContinuation"              : [ "#8B8B8B", "",  "italic"],
    \   "asciidocListingBlock"                  : [ "#009F6F", "",  "italic"],
    \   "asciidocListLabel"                     : [ "SpringGreen2", "",  ""],
    \   "asciidocListNumber"                    : [ "SpringGreen2", "",  ""],
    \   "asciidocLiteralBlock"                  : [ "#009F6F", "",  "italic"],
    \   "asciidocLiteralParagraph"              : [ "#009F6F", "",  "italic"],
    \   "asciidocMacro"                         : ["LightCyan3", "#573D8C", ""],
    \   "asciidocMacroAttributes"               : [ "#7FAAF2", "#1C3644", "bold"],
    \   "asciidocOddnumberedTableCol"           : ["#9FE846", "#573D8C", ""],
    \   "asciidocOneLineTitle"                  : [ "RosyBrown1", "Navy", "bold,italic"],
    \   "asciidocPagebreak"                     : [ "CadetBlue2", "",  ""],
    \   "asciidocPassthroughBlock"              : [ "#009F6F", "",  "italic"],
    \   "asciidocQuoteBlockDelimiter"           : [ "DeepSkyBlue2", "",  ""],
    \   "asciidocQuotedAttributeList"           : [ "#8B8B8B", "",  "italic"],
    \   "asciidocQuotedBold"                    : ["DarkSeaGreen1","#60439A", "italic"],
    \   "asciidocQuotedDoubleQuoted"            : [ "SeaGreen2", "",  "NONE"],
    \   "asciidocQuotedEmphasized"              : ["DarkSeaGreen3","", "italic"],
    \   "asciidocQuotedEmphasized2"             : ["DarkSeaGreen3","", "italic"],
    \   "asciidocQuotedMonospaced"              : [ "#009F6F", "",  "italic"],
    \   "asciidocQuotedMonospaced2"             : [ "#009F6F", "",  "italic"],
    \   "asciidocQuotedSingleQuoted"            : [ "SeaGreen2", "",  "NONE"],
    \   "asciidocQuotedSubscript"               : ["Turquoise2", "#573D8C", ""],
    \   "asciidocQuotedSuperscript"             : ["Turquoise3", "#573D8C", ""],
    \   "asciidocQuotedUnconstrainedBold"       : ["DarkSeaGreen1","#990024", "italic"],
    \   "asciidocQuotedUnconstrainedEmphasized" : [ "DeepSkyBlue2", "",  ""],
    \   "asciidocQuotedUnconstrainedMonospaced" : [ "#009F6F", "",  "italic"],
    \   "asciidocRefMacro"                      : ["LightCyan3", "#573D8C", ""],
    \   "asciidocRuler"                         : [ "DeepSkyBlue2", "",  ""],
    \   "asciidocSidebarDelimiter"              : [ "DeepSkyBlue2", "",  ""],
    \   "asciidocTableBlock"                    : ["#FF88AA", "#573D8C", ""],
    \   "asciidocTableDelimiter"                : [ "Maroon", "",  "bold"],
    \   "asciidocTableDelimiter2"               : [ "#779DB2", "",  ""],
    \   "asciidocTablePrefix"                   : [ "Maroon", "",  "bold"],
    \   "asciidocTablePrefix2"                  : [ "SeaGreen2", "",  "NONE"],
    \   "asciidocToDo"                          : [ "Wheat2", "#345FA8",  ""],
    \   "asciidocTriplePlusPassthrough"         : [ "#88CB35", "",  ""],
    \   "asciidocTwoLineTitle"                  : [ "bg", "CornFlowerBlue",  "bold,italic"],
    \   "asciidocURL"                           : [ "#FFD1FA", "NONE", "underline"],
    \   "Assignment"                            : [ "#F3DB8E", "",  ""],
    \   "awkParen"                              : [ "Red", "",  ""],
    \   "awkPatterns"                           : [ "SpringGreen1", "",  ""],
    \   "awkSpecialPrintf"                      : [ "DodgerBlue1", "",  ""],
    \   "Boolean"                               : [ "CadetBlue2", "",  ""],
    \   "bufferGatorModifiedFileName"           : [ "PaleGreen2", "DarkSlateGray",  "bold,italic"],
    \   "bufferGatorTabpageLine"                : [ "#009F6F", "NONE", "bold"],
    \   "bufferGatorUnmodifiedFileName"         : [ "#8fbfdc", "",  ""],
    \   "builtinFunc"                           : [ "#dad085", "",  "underline"],
    \   "builtinObj"                            : [ "#7F9D90", "", "" ],
    \   "calOperator"                           : [ "#af5f00", "",  ""],
    \   "cBlock"                                : [ "seagreen3", "",  ""],
    \   "cBracket"                              : [ "Green","",""],
    \   "cComment"                              : [ "#8b8b8b","","italic"],
    \   "cConditional"                          : [ "#00B880","","bold"],
    \   "cCppString"                            : ["#D93C76", "", "italic"],
    \   "cDefine"                               : [ "#00B880","",""],
    \   "Character"                             : [ "CadetBlue2", "",  ""],
    \   "cInclude"                              : [ "#00B880","",""],
    \   "cLabel"                                : [ "SkyBlue", "DarkSlateGrey", ""],
    \   "cMulti"                                : ["Red","","bold"],
    \   "cobolLine"                             : [ "DodgerBlue2", "",  ""],
    \   "cobolString"                           : [ "#66aa99", "", "italic"],
    \   "Comment"                               : [ "#8B8B8B", "",  "italic"],
    \   "Conceal"                               : [ "SteelBlue1", "#63728B",  ""],
    \   "Conditional"                           : [ "SeaGreen2", "",  "NONE"],
    \   "Constant"                              : [ "CadetBlue2", "",  ""],
    \   "cOperator"                             : ["CadetBlue2", "",  "bold"],
    \   "cParen"                                : ["Red","",""],
    \   "cppBoolean"                            : ["#00B880","","bold"],
    \   "cppStructure"                          : [ "#8fbfdc", "",  "bold"],
    \   "cppType"                               : ["#00B880", "", "bold"],
    \   "cPreCondit"                            : ["PaleGreen3","","italic,bold"],
    \   "cPreConditMatch"                       : ["PaleGreen3","","italic,bold"],
    \   "cPreProc"                              : [ "#00B880","",""],
    \   "cRepeat"                               : [ "SeaGreen2","","underline"],
    \   "cSpecial"                              : ["Red", "", "italic"],
    \   "cssAuralProp"                          : [ "#88CB35", "",  ""],
    \   "cssBoxProp"                            : [ "#88CB35", "",  ""],
    \   "cssClassName"                          : [ "SeaGreen3",  "#1C3644",  "bold,italic"],
    \   "cssColor"                              : [ "#8870FF", "",  "bold,italic"],
    \   "cssColorProp"                          : [ "#00B880","","bold,italic"],
    \   "cssDefinition"                         : [ "#8870FF", "",  "bold,italic"],
    \   "cssFontAttr"                           : [ "#8870FF", "",  "bold,italic"],
    \   "cssFontDescriptorProp"                 : [ "#88CB35", "",  ""],
    \   "cssFontProp"                           : [ "#2DB3A0", "",  "bold,italic"],
    \   "cssGeneratedContentProp"               : [ "#88CB35", "",  ""],
    \   "cssImportant"                          : [ "#00A600", "",  "bold"],
    \   "cssPagingProp"                         : [ "#88CB35", "",  ""],
    \   "cssRenderProp"                         : [ "#88CB35", "",  ""],
    \   "cssTableProp"                          : [ "#88CB35", "",  ""],
    \   "cssTextProp"                           : [ "#2DB3A0", "",  "bold,italic"],
    \   "cssUIProp"                             : [ "#88CB35", "",  ""],
    \   "cssValueLength"                        : [ "SeaGreen3", "",  ""],
    \   "cStorageClass"                         : ["#00B880","","italic,bold"],
    \   "cStructure"                            : [ "#6A84AD", "#FFD1FA",  "reverse"],
    \   "cTodo"                                 : [ "Wheat2", "#345FA8",  "italic"],
    \   "cType"                                 : [ "#00B880","","bold"],
    \   "Cursor"                                : [ "#8700ff", "orange",  "italic,bold"],
    \   "cursorIM"                              : [ "Black", "OrangeRed",  ""],
    \   "cUserLabel"                            : [ "#8870FF", "",  "bold,underline"],
    \   "dbgBreakPt"                            : [ "", "FireBrick",  ""],
    \   "dbgCurrent"                            : [ "Tomato", "#573d8c",  ""],
    \   "Debug"                                 : [ "#88CB35", "",  ""],
    \   "Decorator"                             : [ "#57d700", "",  ""],
    \   "Define"                                : [ "DodgerBlue2", "",  ""],
    \   "Definition"                            : [ "#f8ed97", "",  ""],
    \   "Delimiter"                             : [ "#779DB2", "",  ""],
    \   "diffAdd"                               : [ "SandyBrown", "DarkOliveGreen",  ""],
    \   "diffAdded"                             : [ "#FFD1FA", "",  ""],
    \   "diffChange"                            : [ "#ddb751", "#556B2F",  "italic"],
    \   "diffChanged"                           : [ "#ddb751", "#556B2F",  "italic"],
    \   "diffDelete"                            : [ "Gray30", "Black",  ""],
    \   "diffFile"                              : [ "#9D0000", "",  ""],
    \   "diffLine"                              : [ "#440000", "",  ""],
    \   "diffNewFile"                           : [ "#9D0000", "",  ""],
    \   "diffRemoved"                           : [ "Gray30", "Black",  ""],
    \   "Directory"                             : [ "DarkOliveGreen2", "",  "bold"],
    \   "dotBraceEncl"                          : [ "SeaGreen2", "",  "NONE"],
    \   "dotBraceErr"                           : [ "Khaki2", "VioletRed4",  ""],
    \   "dotBrackEncl"                          : [ "SeaGreen2", "",  "NONE"],
    \   "dotBrackErr"                           : [ "Khaki2", "VioletRed4",  ""],
    \   "dotIdentifier"                         : [ "#009F6F", "",  "italic"],
    \   "dotKeyChar"                            : [ "SeaGreen2", "",  "NONE"],
    \   "dotKeyword"                            : [ "SeaGreen2", "",  "NONE"],
    \   "dotParEncl"                            : [ "SeaGreen2", "",  "NONE"],
    \   "dotParErr"                             : [ "Khaki2", "VioletRed4",  ""],
    \   "dotString"                             : [ "#99ad6a", "",  ""],
    \   "dottedName"                            : [ "#57d700", "",  ""],
    \   "dotTodo"                               : [ "Wheat2", "Maroon4",  ""],
    \   "dotType"                               : [ "PaleGreen2", "DarkSlateGray",  "italic"],
    \   "Entity"                                : [ "#FF9674", "",  ""],
    \   "Error"                                 : [ "Khaki2", "VioletRed4",  ""],
    \   "errorMsg"                              : [ "LightGoldenRod", "Firebrick",  ""],
    \   "eRubyBlock"                            : [ "#8870FF","","italic"],
    \   "eRubyDelimiter"                        : [ "CadetBlue4", "",  ""],
    \   "eRubyExpression"                       : [ "#009F6F","","bold,italic"],
    \   "Exception"                             : [ "SeaGreen2", "",  "NONE"],
    \   "Float"                                 : [ "Aquamarine2", "",  ""],
    \   "foldColumn"                            : [ "#3E594C", "#082926",  "bold"],
    \   "Folded"                                : [ "PaleGreen2", "DarkSlateGray",  "italic"],
    \   "fountainBold"                          : ["LightCyan3", "#573D8C", ""],
    \   "fountainCentered"                      : ["#E7F56B", "#AD2728", ""  ],
    \   "fountainCharacter"                     : ["#FF88AA", "#573D8C", "italic"],
    \   "fountainDialogue"                      : ["#8ecfbe", "", "italic"],
    \   "fountainPageBreak"                     : [ "#556b2f", "", ""],
    \   "fountainParenthetical"                 : [ "#8B8B8B", "", ""],
    \   "fountainTitlePage"                     : [ "#bfaf69", "", "bold"],
    \   "fountainTransition"                    : ["#BAB585", "#573D8C", ""],
    \   "Function"                              : [ "Turquoise2", "",  ""],
    \   "helpExample"                           : [ "#99AD6A", "",  ""],
    \   "helpHeadline"                          : [ "#5f87df", "",  "bold"],
    \   "helpHypertextEntry"                    : [ "OliveDrab3", "",  "underline"],
    \   "helpHypertextJump"                     : [ "SteelBlue3", "",  "underline"],
    \   "helpNote"                              : [ "PaleGreen1", "DarkSlateGray",  "italic,bold"],
    \   "helpOption"                            : [ "#C59F6F", "",  ""],
    \   "helpSectionDelim"                      : [ "#6CB02D", "",  ""],
    \   "helpSpecial"                           : [ "SeaGreen1", "#305244",  ""],
    \   "helpVim"                               : [ "Wheat", "#2D7067",  "italic,underline"],
    \   "hsStatement"                           : [ "DarkSlateGray2", "SeaGreen",  ""],
    \   "hsStructure"                           : [ "DarkSlateGray2", "SeaGreen",  ""],
    \   "hsVarSym"                              : [ "red", "",  ""],
    \   "htmlArg"                               : [ "#85B2FE", "#1C3644", "italic"],
    \   "htmlBold"                              : [ "SkyBlue2", "",  "italic"],
    \   "htmlComment"                           : [ "Red",      "",  "italic"],
    \   "htmlCommentPart"                       : [ "#802680",  "",  "italic"],
    \   "htmlEndTag"                            : [ "#009F6F","",""],
    \   "htmlEvent"                             : [ "SteelBlue1",  "#1C3644",  "italic"],
    \   "htmlEventDQ"                           : [ "Green3",  "#1C3644",  "italic"],
    \   "htmlH1"                                : [ "White", "CadetBlue4",  "bold"],
    \   "htmlH2"                                : [ "PowderBlue","BurlyWood4",  "bold"],
    \   "htmlH3"                                : [ "#F4E891", "BurlyWood4", "bold,italic"],
    \   "htmlH4"                                : [ "Navy", "cyan4",  "bold,italic"],
    \   "htmlH5"                                : [ "Wheat", "Maroon4",  "bold,italic"],
    \   "htmlH6"                                : [ "#FF88AA", "#66aa99",  "bold,italic"],
    \   "htmlLink"                              : [ "#FFD1FA", "NONE", "underline"],
    \   "htmlSpecialChar"                       : [ "#2DB3A0", "",  ""],
    \   "htmlSpecialTagName"                    : [ "Turquoise3", "",  ""],
    \   "htmlString"                            : [ "#66aa99", "", "italic"],
    \   "htmlTag"                               : [ "#009F6F","",""],
    \   "htmlTagN"                              : [ "#8B8B8B", "", ""],
    \   "htmlTagName"                           : [ "Red", "", ""],
    \   "iCursor"                               : [ "white", "red",  ""],
    \   "Identifier"                            : [ "#009F6F", "",  "italic"],
    \   "Ignore"                                : [ "Gray24", "",  ""],
    \   "Import"                                : [ "#cda869", "",  ""],
    \   "Include"                               : [ "DodgerBlue2", "",  ""],
    \   "incSearch"                             : [ "Firebrick1", "",  "BOLD"],
    \   "indentGuidesEven"                      : ["", "#3D2B6B", ""],
    \   "indentGuidesOdd"                       : ["", "#1c3644", ""],
    \   "javaAnnotation"                        : [ "#8870FF","","italic"],
    \   "javaAssert"                            : [ "SeaGreen2", "",  "NONE"],
    \   "javaBoolean"                           : [ "CadetBlue2", "",  ""],
    \   "javaBranch"                            : [ "SeaGreen2", "",  "NONE"],
    \   "javaCharacter"                         : [ "CadetBlue2", "",  ""],
    \   "javaClassDecl"                         : [ "#00B880","","italic,underline"],
    \   "javaComment"                           : [ "#7D728C", "",  "italic"],
    \   "javaComment2String"                    : [ "#78B37A","",""],
    \   "javaCommentCharacter"                  : [ "blue","",""],
    \   "javaCommentStar"                       : [ "#7D728C", "",  "italic"],
    \   "javaCommentString"                     : [ "#78B37A","",""],
    \   "javaCommentTitle"                      : [ "#78B37A", "",  "italic"],
    \   "javaConditional"                       : [ "SeaGreen2","","bold"],
    \   "javaConstant"                          : [ "MediumSlateBlue","",""],
    \   "javaDocComment"                        : [ "#8B8B8B", "",  "italic"],
    \   "javaDocParam"                          : [ "Turquoise2", "",  ""],
    \   "javaDocTags"                           : [ "#88CB35", "",  ""],
    \   "javaError"                             : [ "Khaki2", "VioletRed4",  ""],
    \   "javaExceptions"                        : [ "SeaGreen3","","italic"],
    \   "javaExternal"                          : [ "#C6B6FE", "#062926",  ""],
    \   "javaFold"                              : [ "#FFD1FA","","bold"],
    \   "javaFuncBody"                          : [ "PaleGreen2", "DarkSlateGray",  "italic"],
    \   "javaFuncDef"                           : [ "Turquoise2", "",  ""],
    \   "javaLabel"                             : [ "SeaGreen2", "",  "NONE"],
    \   "javaLangObject"                        : [ "#7F9D90", "", "" ],
    \   "javaLineComment"                       : [ "#5E8C60", "", ""],
    \   "javaMethodDecl"                        : [ "Aquamarine3", "",  "italic"],
    \   "javaNumber"                            : [ "Aquamarine2", "",  ""],
    \   "javaOperator"                          : [ "Aquamarine3", "",  "italic"],
    \   "javaParenT"                            : [ "GoldenRod", "DarkCyan",  "bold"],
    \   "javaRepeat"                            : [ "SeaGreen1","","bold"],
    \   "javaScopeDecl"                         : [ "#009F6F","","bold,italic"],
    \   "javascriptBoolean"                     : ["PowderBlue", "", "italic"],
    \   "javascriptBraces"                      : [ "#009F6F","","bold"],
    \   "javascriptCommentTodo"                 : [ "#C6B6FE", "#345FA8",  "italic"],
    \   "javascriptConditional"                 : [ "SeaGreen3","","italic"],
    \   "javascriptFunction"                    : [ "LimeGreen", "#1C3644", "italic"],
    \   "javascriptGlobal"                      : [ "#009F6F","","bold,italic"],
    \   "javascriptIdentifier"                  : [ "#2DB3A0", "",  "bold,italic"],
    \   "javascriptMember"                      : [ "SeaGreen3","","italic"],
    \   "javascriptMessage"                     : [ "#66aa99",  "#1C3644",  "italic"],
    \   "javascriptNull"                        : [ "CadetBlue3","",""],
    \   "javascriptOperator"                    : [ "#2DB3A0","","underline"],
    \   "javascriptParens"                      : [ "#2DB3A0", "",  "italic"],
    \   "javascriptRegexpString"                : ["CadetBlue3", "#1C3644", "italic"],
    \   "javascriptRepeat"                      : [ "SeaGreen3",  "#1C3644",  "italic"],
    \   "javascriptSpecial"                     : [ "#7697d6", "",  "italic"],
    \   "javascriptStatement"                   : [ "SeaGreen2",  "#1C3644",  "italic"],
    \   "javascriptStringD"                     : [ "#7697d6", "",  "italic"],
    \   "javascriptStringS"                     : [ "#66aa99", "", "italic"],
    \   "javascriptType"                        : [ "#009F6F","","bold"],
    \   "javaScriptValue"                       : [ "CadetBlue2", "",  ""],
    \   "javaSpecial"                           : [ "#88CB35", "",  ""],
    \   "javaSpecialChar"                       : [ "#88CB35", "",  ""],
    \   "javaSpecialCharError"                  : [ "Khaki2", "VioletRed4",  ""],
    \   "javaSpecialError"                      : [ "Khaki2", "VioletRed4",  ""],
    \   "javaStatement"                         : [ "#2DB3A0", "",  "italic"],
    \   "javaStorageClass"                      : ["#7EB49C", "", "italic"],
    \   "javaString"                            : ["CadetBlue3", "",  "italic"],
    \   "javaStringError"                       : [ "Khaki2", "VioletRed4",  ""],
    \   "javaTodo"                              : ["Wheat2", "#345FA8",  "italic"],
    \   "javaType"                              : [ "#00B880","","italic"],
    \   "javaTypeDef"                           : [ "#009F6F","",""],
    \   "javaUserLabel"                         : [ "SeaGreen2", "",  "NONE"],
    \   "javaUserLabelRef"                      : [ "SeaGreen2", "",  "NONE"],
    \   "Keyword"                               : [ "SeaGreen2", "",  "NONE"],
    \   "level15"                               : [ "Aquamarine3", "",  "italic"],
    \   "level16"                               : [ "#2DB3A0", "",  "italic"],
    \   "lineNr"                                : [ "DarkSeaGreen4", "#0C2628",  ""],
    \   "luaOperator"                           : ["PaleGreen3","","bold,underline"],
    \   "m4Preproc"                             : [ "SeaGreen3",  "#1C3644",  "bold"],
    \   "m4String"                              : [ "#8fbfdc","","italic"],
    \   "m4Type"                                : [ "Aquamarine2", "",  "bold"],
    \   "m4Variable"                            : [ "Red", "",  ""],
    \   "Macro"                                 : [ "DodgerBlue2", "",  ""],
    \   "makeCommandError"                      : [ "#8870FF", "",  "bold"],
    \   "makeDString"                           : [ "LimeGreen", "",  ""],
    \   "makeIdent"                             : [ "Aquamarine3", "",  ""],
    \   "makePreCondit"                         : [ "#8870FF", "",  "bold"],
    \   "makeSpecial"                           : [ "Red", "",  ""],
    \   "makeTarget"                            : [ "#00B880","","bold,underline"],
    \   "manReference"                          : [ "DodgerBlue2", "",  "italic"],
    \   "manTitle"                              : [ "Green", "#2D8D67",  "underline"],
    \   "markdownAutomaticLink"                 : [ "#FFD1FA", "NONE", "underline"],
    \   "markdownBlockquote"                    : [ "#99ad6a", "",  ""],
    \   "markdownBold"                          : ["PaleGreen2","#082926", "bold" ],
    \   "markdownBoldItalic"                    : [ "RoyalBlue", "#062926",  "bold,italic"],
    \   "markdownCode"                          : [ "SeaGreen2", "",  "NONE"],
    \   "markdownCodeBlock"                     : [ "SeaGreen2", "",  "NONE"],
    \   "markdownEscape"                        : [ "DodgerBlue2", "",  ""],
    \   "markdownH1"                            : [ "Black", "LimeGreen",  "bold"],
    \   "markdownH2"                            : [ "PaleGoldenrod", "#0e2628",  ""],
    \   "markdownH3"                            : [ "LightBlue2","PaleTurquoise4",  "bold,italic"],
    \   "markdownH4"                            : [ "LightBlue2", "BurlyWood4", "bold,italic"],
    \   "markdownH5"                            : [ "Wheat", "Maroon4",  ""],
    \   "markdownH6"                            : [ "#FDD99B", "#CCFFCC",  ""],
    \   "markdownHeadingDelimiter"              : [ "#8B8B8B", "",  "italic"],
    \   "markdownHeadingRule"                   : [ "#8B8B8B", "",  "italic"],
    \   "markdownItalic"                        : [ "PaleGreen2", "DarkSlateGray",  "italic"],
    \   "markdownLineBreak"                     : [ "Wheat2", "Maroon4",  ""],
    \   "markdownLinkDelimiter"                 : [ "#8B8B8B", "",  "italic"],
    \   "markdownLinkText"                      : [ "#FFD1FA", "NONE", "underline"],
    \   "markdownLinkTextDelimiter"             : [ "#8B8B8B", "",  "italic"],
    \   "markdownListMarker"                    : [ "SpringGreen2", "",  ""],
    \   "markdownOrderedListMarker"             : [ "SpringGreen2", "",  ""],
    \   "markdownRule"                          : [ "#8B8B8B", "",  "italic"],
    \   "markdownUrl"                           : [ "#66aa99", "", "italic"],
    \   "markdownUrlDelimiter"                  : [ "#779DB2", "",  ""],
    \   "markdownUrlTitle"                      : [ "SeaGreen2", "",  "NONE"],
    \   "markdownUrlTitleDelimiter"             : [ "#779DB2", "",  ""],
    \   "markdownValid"                         : [ "#C6B6FE", "#062926",  ""],
    \   "matchParen"                            : [ "GoldenRod", "DarkCyan",  "bold"],
    \   "mkdBlockCode"                          : [ "SeaGreen2", "",  "NONE"],
    \   "mkdBlockquote"                         : [ "#99ad6a", "",  ""],
    \   "mkdCode"                               : [ "SeaGreen2", "",  "NONE"],
    \   "mkdDelimiter"                          : [ "#779DB2", "",  ""],
    \   "mkdID"                                 : [ "SeaGreen2", "",  "NONE"],
    \   "mkdLineBreak"                          : [ "Wheat2", "Maroon4",  ""],
    \   "mkdLineContinue"                       : [ "#8B8B8B", "",  "italic"],
    \   "mkdLink"                               : [ "#8B8B8B", "",  "italic"],
    \   "mkdLinkDef"                            : [ "#FFD1FA", "NONE", "underline"],
    \   "mkdLinkDefTarget"                      : [ "#66aa99", "", "italic"],
    \   "mkdLinkTitle"                          : [ "SeaGreen2", "",  "NONE"],
    \   "mkdListCode"                           : [ "#009F6F", "",  "italic"],
    \   "mkdListItem"                           : ["AquaMarine2", "", "italic"],
    \   "mkdRule"                               : [ "#8B8B8B", "",  "italic"],
    \   "mkdString"                             : [ "#99ad6a", "",  ""],
    \   "mkdURL"                                : [ "#66aa99", "", "italic"],
    \   "modeMsg"                               : [ "OliveDrab4", "",  ""],
    \   "moreMsg"                               : [ "DarkCyan", "",  ""],
    \   "nerdtreeDir"                           : [ "SkyBlue2", "",  "underline"],
    \   "nerdtreeDirSlash"                      : [ "Red", "",  "bold"],
    \   "nerdtreeFile"                          : [ "#00B880","","italic"],
    \   "nerdtreeHelp"                          : [ "#C6B6FE", "#062926",  ""],
    \   "nerdtreePart"                          : ["SlateBlue2", "", "bold"],
    \   "nerdtreeUp"                            : [ "#00B880","","bold"],
    \   "netrwClassify"                         : [ "Red", "",  "bold"],
    \   "netrwComment"                          : [ "#C6B6FE", "#062926",  ""],
    \   "netrwDir"                              : [ "SkyBlue2", "",  "underline"],
    \   "netrwHelpCmd"                          : [ "Wheat", "#2D7067",  ""],
    \   "netrwPlain"                            : [ "#00B880","","italic"],
    \   "netrwQuickHelp"                        : [ "Wheat", "#2D7067",  ""],
    \   "netrwVersion"                          : [ "#5f87d7", "",  "italic"],
    \   "nonText"                               : [ "#0F450F", "",  ""],
    \   "Number"                                : [ "Aquamarine2", "",  ""],
    \   "ocamlAnyVar"                           : [ "#85B2FE", "", "bold"],
    \   "ocamlComment"                          : ["#78B37A", "", "italic"],
    \   "ocamlConstructor"                      : [ "CadetBlue3", "",  "italic"],
    \   "ocamlKeyChar"                          : ["Red", "", ""],
    \   "ocamlLCIdentifier"                     : ["DarkCyan", "", "bold"],
    \   "ocamlSig"                              : ["OrangeRed", "", ""],
    \   "Operator"                              : [ "SpringGreen2", "",  ""],
    \   "paramName"                             : [ "#5f87d7", "",  ""],
    \   "perlComment"                           : [ "#77996C", "",  "italic"],
    \   "perlConditional"                       : [ "SeaGreen3",  "#1C3644",  "italic"],
    \   "perlControl"                           : [ "SkyBlue", "DarkSlateGrey", "bold"],
    \   "perlFileDescRead"                      : [ "#A08EF8", "",  "bold"],
    \   "perlFileDescStatement"                 : [ "#A08EF8", "",  "bold"],
    \   "perlFunction"                          : [ "#32C5B0", "", "bold"],
    \   "perlFunctionName"                      : [ "Aquamarine3", "",  ""],
    \   "perlIdentifier"                        : [ "OliveDrab3", "",  "underline"],
    \   "perlLabel"                             : [ "PaleGreen2", "DarkSlateGray",  "italic"],
    \   "perlMatch"                             : [ "Red", "",  ""],
    \   "perlMatchStartEnd"                     : [ "Red", "",  ""],
    \   "perlMethod"                            : [ "#67BF54", "#1C3644", "italic"],
    \   "perlOperator"                          : [ "SpringGreen2", "",  ""],
    \   "perlPackageRef"                        : [ "#7fa2e6", "",  "bold"],
    \   "perlRepeat"                            : [ "SeaGreen3",  "#1C3644",  "bold,italic"],
    \   "perlSharpBang"                         : [ "#81A676", "",  ""],
    \   "perlSpecialMatch"                      : [ "#7fa2e6", "",  "italic"],
    \   "perlSpecialString"                     : [ "Red", "",  ""],
    \   "perlStatementControl"                  : [ "Aquamarine3", "",  "italic"],
    \   "perlStatementFileDesc"                 : [ "Aquamarine3", "",  ""],
    \   "perlStatementFiles"                    : [ "Aquamarine3", "",  ""],
    \   "perlStatementFlow"                     : [ "SeaGreen3",  "#1C3644",  "italic"],
    \   "perlStatementList"                     : [ "seagreen3", "",  ""],
    \   "perlStatementScalar"                   : [ "#00CC8A", "",  "italic"],
    \   "perlStatementStorage"                  : [ "#00CC8A", "",  "italic"],
    \   "perlString"                            : [ "#7fa2e6", "",  "italic"],
    \   "perlStringStartEnd"                    : [ "SpringGreen2", "",  ""],
    \   "perlStringUnexpanded"                  : [ "#00BA83","","italic"],
    \   "perlSubName"                           : [ "#32C5B0", "",  "bold"],
    \   "perlSubPrototype"                      : [ "Red", "",  ""],
    \   "perlTodo"                              : [ "Wheat2", "#345FA8",  "italic"],
    \   "perlVarPlain"                          : [ "#00BA83","","italic"],
    \   "perlVarPlain2"                         : [ "#2DB3A0", "",  "italic"],
    \   "perlVarSimpleMember"                   : [ "Red", "",  ""],
    \   "perlVarSlash"                          : ["#41E7B5", "",  "bold,italic"],
    \   "phpArrayPair"                          : [ "#2DB3A0", "",  "italic"],
    \   "phpBoolean"                            : [ "MediumSlateBlue","",""],
    \   "phpFunctions"                          : [ "#85B2FE", "#1C3644", ""],
    \   "phpNull"                               : [ "MediumSlateBlue","",""],
    \   "phpQuoteDouble"                        : [ "#8CA854", "",  ""],
    \   "phpQuoteSingle"                        : [ "#8CA854", "",  ""],
    \   "phpSuperGlobal"                        : [ "#2DB3A0", "",  "bold,italic"],
    \   "plibuiltin"                            : ["steelblue2", "", ""],
    \   "plidelimiter"                          : ["red", "", ""],
    \   "plsqlBooleanLiteral"                   : [ "#009F6F","","italic,underline"],
    \   "plsqlConditional"                      : [ "#009F6F","","italic,underline"],
    \   "plsqlFunction"                         : [ "SkyBlue2", "",  "italic"],
    \   "plsqlGarbage"                          : [ "#7FAAF2", "#1C3644", "italic"],
    \   "plsqlHostIdentifier"                   : ["SlateBlue1", "",  ""],
    \   "plsqlIdentifier"                       : [ "#7FAAF2", "#1C3644", ""],
    \   "plsqlIntLiteral"                       : ["Aquamarine3","",""],
    \   "plsqlKeyword"                          : [ "#009F6F","","italic,underline"],
    \   "plsqlOperator"                         : [ "#2DB3A0", "",  "italic"],
    \   "plsqlRepeat"                           : [ "#8870FF", "",  "italic"],
    \   "plsqlSQLKeyword"                       : [ "#009F6F","","bold"],
    \   "plsqlStorage"                          : ["CornFlowerBlue","",""],
    \   "plsqlStringError"                      : ["red","#63728B","bold"],
    \   "plsqlStringLiteral"                    : ["Aquamarine3", "",  "italic"],
    \   "plsqlSymbol"                           : ["red","","bold"],
    \   "pMenu"                                 : [ "Gray", "MediumPurple4",  ""],
    \   "pMenuSbar"                             : [ "Tan", "SeaShell4",  ""],
    \   "pMenuSel"                              : [ "Wheat", "Maroon4",  ""],
    \   "pMenuThumb"                            : [ "Tomato", "SeaShell4",  ""],
    \   "preciseJumpTarget"                     : [ "#8700ff", "orange",  ""],
    \   "preCondit"                             : [ "DodgerBlue2", "",  ""],
    \   "preProc"                               : [ "DodgerBlue2", "",  ""],
    \   "pythonArithmetic"                      : ["#41E7B5", "",  "bold"],
    \   "pythonAssignment"                      : ["#7FC090", "",  "bold"],
    \   "pythonBinError"                        : [ "Khaki2", "VioletRed4",  ""],
    \   "pythonBinNumber"                       : [ "Aquamarine2", "",  ""],
    \   "pythonBuiltinFunc"                     : [ "#7FC090","","bold"],
    \   "pythonBuiltinLogic"                    : [ "Aquamarine2", "",  ""],
    \   "pythonBuiltinObj"                      : [ "#7FC090","",""],
    \   "pythonCalOperator"                     : [ "#af5f00", "",  ""],
    \   "pythonClassDef"                        : [ "SeaGreen3",  "#1C3644",  "bold,italic"],
    \   "pythonClassName"                       : [ "SeaGreen3",  "#1C3644",  "bold,italic"],
    \   "pythonCoding"                          : [ "#88CB35", "",  ""],
    \   "pythonComment"                         : [ "#66aa99", "",  "italic"],
    \   "pythonComparison"                      : ["SpringGreen3", "",  "bold"],
    \   "pythonConditional"                     : ["SlateBlue1", "",  "underline"],
    \   "pythonDecorator"                       : [ "#F8ED97", "", "italic"],
    \   "pythonDefaultAssignment"               : ["#7FC090", "",  "bold"],
    \   "pythonDocstring"                       : [ "#77996C", "",  "italic"],
    \   "pythonDocTest"                         : ["#C59F6F", "bg", "" ],
    \   "pythonDocTest2"                        : ["#C59F6F", "bg", "" ],
    \   "pythonDottedName"                      : [ "#57d700", "",  ""],
    \   "pythonError"                           : [ "Khaki2", "VioletRed4",  ""],
    \   "pythonEscape"                          : [ "#FFD1FA", "", ""],
    \   "pythonEscapeError"                     : [ "Khaki2", "VioletRed4",  ""],
    \   "pythonException"                       : ["SlateBlue1", "",  "underline"],
    \   "pythonExClass"                         : [ "#8fbfdc", "",  ""],
    \   "pythonFloat"                           : [ "Aquamarine2", "",  "italic"],
    \   "pythonFuncDef"                         : [ "#85B2FE", "#1C3644", "italic"],
    \   "pythonFuncName"                        : [ "#85B2FE", "#1C3644", "italic"],
    \   "pythonFunction"                        : [ "Turquoise2", "",  ""],
    \   "pythonHexError"                        : [ "Khaki2", "VioletRed4",  ""],
    \   "pythonHexNumber"                       : [ "Aquamarine2", "",  ""],
    \   "pythonIndentError"                     : [ "Khaki2", "VioletRed4",  ""],
    \   "pythonNumber"                          : [ "Aquamarine2", "",  ""],
    \   "pythonOctError"                        : [ "Khaki2", "VioletRed4",  ""],
    \   "pythonOctNumber"                       : [ "Aquamarine2", "",  ""],
    \   "pythonOperator"                        : ["SlateBlue1", "",  "bold"],
    \   "pythonParamDefault"                    : [ "SeaGreen2", "",  "NONE"],
    \   "pythonParamName"                       : [ "#99AD6A", "",  "italic"],
    \   "pythonPreCondit"                       : [ "#009F6F", "", "bold"],
    \   "pythonRawString"                       : [ "#99ad6a", "",  ""],
    \   "pythonRepeat"                          : ["SlateBlue1", "",  "bold,underline"],
    \   "pythonRun"                             : [ "#88CB35", "",  ""],
    \   "pythonSpaceError"                      : [ "", "Tomato", ""],
    \   "pythonStatement"                       : [ "#7FC090","",""],
    \   "pythonStrFormat"                       : [ "#88CB35", "",  ""],
    \   "pythonStrFormatting"                   : [ "#FFAAE8", "", "bold"],
    \   "pythonString"                          : [ "#66aa99", "", "italic"],
    \   "pythonStrTemplate"                     : [ "#88CB35", "",  ""],
    \   "pythonSuperclass"                      : [ "Green2", "#254859", "italic"],
    \   "pythonTodo"                            : [ "Wheat2", "#345FA8",  "italic"],
    \   "pythonUniEscape"                       : [ "#88CB35", "",  ""],
    \   "pythonUniEscapeError"                  : [ "Khaki2", "VioletRed4",  ""],
    \   "pythonUniRawEscape"                    : [ "#88CB35", "",  ""],
    \   "pythonUniRawEscapeError"               : [ "Khaki2", "VioletRed4",  ""],
    \   "pythonUniRawString"                    : [ "#99ad6a", "",  ""],
    \   "pythonUniString"                       : [ "#99ad6a", "",  ""],
    \   "Question"                              : [ "#65C254", "",  ""],
    \   "Repeat"                                : [ "SeaGreen2", "",  "NONE"],
    \   "rstInlineLiteral"                      : [ "#009F6F", "",  ""],
    \   "rstLiteralBlock"                       : [ "#2DB3A0", "",  ""],
    \   "rstSimpleTable"                        : ["#FF88AA", "#573D8C", ""],
    \   "rstTable"                              : ["#FF88AA", "#573D8C", ""],
    \   "rubyBlock"                             : [ "#D93C76","",""],
    \   "rubyBlockParameter"                    : [ "Wheat", "Maroon4",  ""],
    \   "rubyBlockParameterList"                : [ "#D93C76","",""],
    \   "rubyCaseExpression"                    : [ "#8870FF", "",  "italic"],
    \   "rubyClass"                             : [ "#009F6F","","bold,italic"],
    \   "rubyComment"                           : ["#5B8999", "", "italic"],
    \   "rubyConditional"                       : [ "SeaGreen3","",""],
    \   "rubyConstant"                          : [ "#009F6F","","italic"],
    \   "rubyControl"                           : [ "#009F6F","","bold,italic"],
    \   "rubyCurlyBlock"                        : [ "#c6b6fe", "",  ""],
    \   "rubyDefine"                            : [ "#85B2FE", "#1C3644", "italic"],
    \   "rubyDoBlock"                           : [ "#009F6F","",""],
    \   "rubyFunction"                          : [ "#2DB3A0", "",  "italic"],
    \   "rubyGlobalVariable"                    : [ "SkyBlue", "",  ""],
    \   "rubyIdentifier"                        : [ "#c6b6fe", "",  ""],
    \   "rubyInclude"                           : [ "SeaGreen3","",""],
    \   "rubyInstanceVariable"                  : [ "SkyBlue", "",  ""],
    \   "rubyInterpolationDelimiter"            : [ "#A6D3D9", "", "bold"],
    \   "rubyLocalVariableOrMethod"             : [ "#009F6F","","bold,italic"],
    \   "rubyMethodBlock"                       : [ "#8870FF", "",  "italic"],
    \   "rubyModule"                            : [ "#009F6F", "",  "underline"],
    \   "rubyPredefinedIdentifier"              : [ "#de5577", "",  ""],
    \   "rubyPseudoVariable"                    : [ "#8870FF", "",  ""],
    \   "rubyRegexp"                            : [ "#99AD6a", "",  "bold"],
    \   "rubyRegexpCharClass"                   : [ "#D93C76", "", ""],
    \   "rubyRegexpDelimiter"                   : [ "Red", "", "bold"],
    \   "rubyRegexpSpecial"                     : [ "#E600A0", "",  "bold"],
    \   "rubySharpBang"                         : [ "#77996C", "",  "italic"],
    \   "rubyString"                            : [ "#99ad6a", "",  ""],
    \   "rubyStringDelimiter"                   : [ "#8CA854", "",  ""],
    \   "rubyStringEscape"                      : [ "#99AD6a", "",  ""],
    \   "rubySymbol"                            : [ "#7697d6", "",  ""],
    \   "scalaClassDecl"                        : [ "#c59f6f", "",  ""],
    \   "scalaFunction"                         : [ "Aquamarine3", "",  "bold,italic"],
    \   "scalaLineComment"                      : [ "#78B37A", "",  ""],
    \   "scalaStorageClass"                     : [ "#c59f6f", "",  "italic"],
    \   "scalaTypeDef"                          : [ "Turquoise2", "",  ""],
    \   "shCase"                                : [ "PowderBlue", "",  ""],
    \   "shCaseDoubleQuote"                     : [ "#6A84AD", "bg",  "reverse"],
    \   "shCaseEsac"                            : [ "Aquamarine3", "",  "italic"],
    \   "shColon"                               : [ "AquaMarine3", "",  ""],
    \   "shCommandSub"                          : [ "#49BEF3", "",  "italic"],
    \   "shComment"                             : [ "#8B8B8B", "",  "italic"],
    \   "shConditional"                         : [ "#009F6F","","bold"],
    \   "shDblBrace"                            : ["#009F6F", "", "bold"],
    \   "shDblParen"                            : ["#009F6F", "", "bold"],
    \   "shDeRefPattern"                        : [ "#49BEF3", "",  "italic"],
    \   "shDeRefPPSleft"                        : [ "#99AD6A", "",  "italic"],
    \   "shDeRefPPSright"                       : [ "#99AD6A", "",  "italic"],
    \   "shDeRefSimple"                         : [ "#99AD6A", "",  "italic"],
    \   "shDeRefVar"                            : [ "#7FAAF2", "",  "italic"],
    \   "shDo"                                  : [ "#8FBFDC", "",  "italic"],
    \   "shDoubleQuote"                         : [ "#2DB3A0", "",  "italic"],
    \   "shFor"                                 : [ "Aquamarine3", "",  "italic"],
    \   "shFunction"                            : ["PaleGreen3","", "italic,bold"],
    \   "shFunctionKey"                         : [ "#009F6F","","italic"],
    \   "shFunctionOne"                         : [ "#2DB3A0", "",  "bold,italic"],
    \   "shFunctionTwo"                         : ["SlateBlue2", "", ""],
    \   "shIf"                                  : [ "#8870FF", "",  "bold,italic"],
    \   "shLoop"                                : [ "AquaMarine2", "",  "bold,italic"],
    \   "shOperator"                            : [ "Red", "",  ""],
    \   "shOption"                              : [ "#8870FF", "",  "bold"],
    \   "shParen"                               : [ "#009F6F","","bold,italic"],
    \   "shSet"                                 : [ "#009F6F", "",  "bold"],
    \   "shSetIdentifier"                       : [ "SteelBlue2", "",  "bold"],
    \   "shSetList"                             : [ "#2DB3A0", "",  ""],
    \   "shSnglCase"                            : [ "Red", "",  ""],
    \   "shStatement"                           : [ "Aquamarine3", "",  "italic"],
    \   "shTestPattern"                         : ["#99ad6a", "", "bold,italic"],
    \   "shTodo"                                : [ "Wheat2", "#345FA8",  "italic"],
    \   "shVariable"                            : [ "#009F6F", "#1C3644", "italic"],
    \   "signColor"                             : ["#C59F6F", "bg", "" ],
    \   "signColumn"                            : [ "PaleGoldenrod", "#0e2628",  ""],
    \   "Special"                               : [ "#88CB35", "",  ""],
    \   "specialChar"                           : [ "#88CB35", "",  ""],
    \   "specialKey"                            : [ "RosyBrown3", "",  ""],
    \   "sqlKeyword"                            : ["PaleGreen3","","italic,bold"],
    \   "sqlNumber"                             : [ "#85B2FE", "#1C3644", "italic"],
    \   "sqlOperator"                           : [ "#8870FF", "",  "italic"],
    \   "sqlSpecial"                            : [ "#99AD6A", "",  ""],
    \   "sqlStatement"                          : ["PaleGreen3","","bold,italic,underline"],
    \   "sqlString"                             : [ "#009F6F","","bold"],
    \   "sqlType"                               : ["#00B880","","italic"],
    \   "Statement"                             : [ "SeaGreen2", "",  "NONE"],
    \   "statusLine"                            : [ "LemonChiffon2", "#334680",  "bold"],
    \   "statusLineNC"                          : [ "Honeydew3", "Gray22",  ""],
    \   "storageClass"                          : [ "#c59f6f", "",  ""],
    \   "String"                                : [ "#99ad6a", "",  ""],
    \   "stringDelimiter"                       : [ "#8CA854", "",  ""],
    \   "Structure"                             : [ "#8fbfdc", "",  ""],
    \   "superclass"                            : [ "#6A84AD", "#FFD1FA",  "reverse"],
    \   "tabLine"                               : [ "CornflowerBlue", "Gray26",  "italic"],
    \   "tabLineClose"                          : [ "CornflowerBlue",    "Gray26",           "bold"],
    \   "tabLineFill"                           : [ "CornflowerBlue", "Gray20",  "UNDERLINE"],
    \   "tabLineNumber"                         : [ "#3CEEB3",    "Gray26",           "bold"],
    \   "tabLineSel"                            : [ "RoyalBlue", "#062926",  "bold,italic"],
    \   "Tag"                                   : [ "#88CB35", "",  ""],
    \   "tagListComment"                        : [ "#66aa99", "#062926",  ""],
    \   "tagListFileName"                       : [ "SeaGreen3", "#473273", "bold,italic"],
    \   "tagListTagScope"                       : [ "#66aa99",  "",  ""],
    \   "tagListTitle"                          : [ "SeaGreen3",  "#1C3644",  "bold,italic"],
    \   "texComment"                            : [ "#78B37A", "",  "italic"],
    \   "texDelimiter"                          : ["Red", "", ""],
    \   "texDocZone"                            : [ "#85B2FE", "#1C3644", ""],
    \   "texSectionName"                        : [ "#BE00CC",  "", "bold"],
    \   "texSectionZone"                        : ["Green", "", ""],
    \   "texSpecialChar"                        : [ "Red", "",  ""],
    \   "texStatement"                          : ["#D93C76", "", "bold"],
    \   "texTitle"                              : [ "Green2", "#254859", ""],
    \   "Title"                                 : [ "#009F6F", "", "bold,italic"],
    \   "Todo"                                  : [ "Wheat2", "Maroon4",  ""],
    \   "Type"                                  : [ "DeepSkyBlue2", "",  ""],
    \   "Typedef"                               : [ "DeepSkyBlue2", "",  ""],
    \   "Underlined"                            : [ "SkyBlue2", "",  "UNDERLINE"],
    \   "vertSplit"                             : [ "RoyalBlue", "#573D8C",  "bold"],
    \   "vimAuGroup"                            : [ "SlateBlue2", "",  ""],
    \   "vimAutoCmd"                            : [ "SeaGreen2", "",  ""],
    \   "vimAutoCmdSfxList"                     : [ "#85B2FE", "",  ""],
    \   "vimAutoevent"                          : [ "#32C5B0", "",  ""],
    \   "vimAutoeventList"                      : [ "SeaGreen3", "",  ""],
    \   "vimBracket"                            : [ "Red", "DarkSlateGray",  ""],
    \   "vimCmdSep"                             : [ "red", "",  "bold"],
    \   "vimCommand"                            : [ "SeaGreen3", "",  "italic"],
    \   "vimCommentTitle"                       : [ "#8B7F4C", "",  "bold,italic"],
    \   "vimContinue"                           : [ "SlateBlue2", "",  ""],
    \   "vimEcho"                               : [ "Red", "",  "bold"],
    \   "vimExecute"                            : [ "SkyBlue", "DarkSlateGrey", "italic"],
    \   "vimVar"                                : [ "SteelBlue2", "",  "italic"],
    \   "vimFBvar"                              : [ "SteelBlue2", "",  "italic"],
    \   "vimFuncBody"                           : [ "Red", "",   ""],
    \   "vimFuncKey"                            : [ "SeaGreen3", "#1C3644", "bold,italic"],
    \   "vimFuncName"                           : [ "#32C5B0", "", "underline"],
    \   "vimFunction"                           : [ "SeaGreen3", "#1C3644", "italic"],
    \   "vimFuncVar"                            : [ "SteelBlue3", "",  "underline,italic"],
    \   "vimGroup"                              : [ "SteelBlue1",    "DarkSlateGrey", "NONE"],
    \   "vimHiClear"                            : [ "#A8C2EF",    "DarkSlateGrey", "NONE"],
    \   "vimHiCterm"                            : [ "DeepSkyBlue3", "", ""],
    \   "vimHiCtermColor"                       : [ "SteelBlue1",   "DarkSlateGrey", "NONE"],
    \   "vimHiCtermFgBg"                        : [ "DeepSkyBlue3", "", ""],
    \   "vimHighLight"                          : [ "#A8C2EF",    "DarkSlateGrey", "NONE"],
    \   "vimHiGroup"                            : [ "SteelBlue1",   "DarkSlateGrey", "NONE"],
    \   "vimHiGui"                              : [ "DeepSkyBlue3", "", ""],
    \   "vimHiGuiFgBg"                          : [ "DeepSkyBlue3", "", ""],
    \   "vimHiGuiRGB"                           : [ "SteelBlue1",    "DarkSlateGrey",  ""],
    \   "vimHiKeyList"                          : [ "#2DB3A0", "",  ""],
    \   "vimIsCommand"                          : [ "#9CD9CB", "",  "italic"],
    \   "vimLineComment"                        : [ "#8B8B8B", "",  "NONE"],
    \   "vimMapLHS"                             : [ "SkyBlue2", "",  "bold"],
    \   "vimMapModKey"                          : [ "#2DB3A0", "",  "italic"],
    \   "vimMapRHS"                             : [ "SkyBlue2", "",  "italic"],
    \   "vimMenuLHS"                            : [ "SeaGreen4", "",  ""],
    \   "vimMenuName"                           : [ "SeaGreen3", "",  ""],
    \   "vimMenuRHS"                            : [ "SeaGreen4", "",  "italic"],
    \   "vimNormCmds"                           : [ "#85B2FE", "",  "bold,italic"],
    \   "vimNotation"                           : [ "#CEC2F7", "#63728B",  ""],
    \   "vimNotFunc"                            : [ "SeaGreen3", "",  "bold"],
    \   "vimNumber"                             : [ "Aquamarine2", "",  ""],
    \   "vimOper"                               : [ "SeaGreen3", "",  "bold"],
    \   "vimOperError"                          : [ "SeaGreen3", "",  ""],
    \   "vimOperParen"                          : [ "SteelBlue2", "",  "italic"],
    \   "vimOption"                             : [ "#85B2FE",    "DarkSlateGrey", "NONE"],
    \   "vimParenSep"                           : [ "red", "",  ""],
    \   "vimPatOneOrMore"                       : [ "red", "",  ""],
    \   "vimPatRegionClose"                     : ["SeaGreen2", "",  "bold"],
    \   "vimPatRegionOpen"                      : [ "SeaGreen2", "",  "bold"],
    \   "vimPatSep"                             : [ "SeaGreen2", "",  ""],
    \   "vimPatSepR"                            : [ "SeaGreen3", "",  ""],
    \   "vimPythonRegion"                       : [ "#41E7B5",    "",  ""],
    \   "vimRegister"                           : [ "#8870FF", "",  ""],
    \   "vimSep"                                : [ "SlateBlue2", "", ""],
    \   "vimSet"                                : [ "SeaGreen3", "", ""],
    \   "vimSetEqual"                           : [ "PaleGreen3", "DarkSlateGrey", "NONE"],
    \   "vimSetSep"                             : [ "PaleGreen3", "DarkSlateGrey", "NONE"],
    \   "vimSpecFile"                           : [ "#8870FF", "",  ""],
    \   "vimSpecial"                            : [ "DeepSkyBlue3", "",  ""],
    \   "vimString"                             : [ "#99AD6A", "",  ""],
    \   "vimSubst"                              : [ "DodgerBlue", "",  ""],
    \   "vimSubst1"                             : [ "DodgerBlue1", "",  "bold"],
    \   "vimSubstDelim"                         : [ "Red", "",  "bold"],
    \   "vimSubstFlags"                         : [ "DodgerBlue3", "",  "italic"],
    \   "vimSubstPat"                           : [ "DodgerBlue2", "",  "bold"],
    \   "vimSubstRep4"                          : [ "DodgerBlue3", "",  "bold"],
    \   "vimSubstSubstr"                        : [ "SkyBlue3", "",  ""],
    \   "vimSynType"                            : [ "#69AB2C", "",  ""],
    \   "vimTodo"                               : [ "Wheat2", "#345FA8",  ""],
    \   "vimUserAttrbKey"                       : [ "#32C5B0", "",  "italic"],
    \   "vimUserCmd"                            : [ "SeaGreen3", "", ""],
    \   "vimUserFunc"                           : [ "#85B2FE", "#1C3644", ""],
    \   "Visual"                                : [ "Navy", "DarkSeaGreen3", "bold"],
    \   "visualNOS"                             : [ "SlateGray3", "",  "BOLD,UNDERLINE"],
    \   "warningMsg"                            : [ "Gold", "",  ""],
    \   "wildMenu"                              : [ "Black", "LimeGreen",  "bold"],
    \   "xmlAttrib"                             : [ "#cda8c9", "#102010",  ""],
    \   "xmlCDATA"                              : [ "PaleGreen2", "DarkSlateGrey",  "bold,italic"],
    \   "xmlCDATAcdata"                         : [ "Khaki4", "DarkSlateGrey",  "italic"],
    \   "xmlCDATAend"                           : [ "Khaki4", "DarkSlateGrey",  "italic"],
    \   "xmlCDATAstart"                         : [ "Khaki4", "DarkSlateGrey",  "italic"],
    \   "xmlComment"                            : [ "Red",      "",  "italic"],
    \   "xmlCommentPart"                        : [ "#802680",  "",  "italic"],
    \   "xmlEndTag"                             : ["#00B880", "",  "italic"],
    \   "xmlEqual"                              : [ "#009F6F","","bold"],
    \   "xmlNameSpace"                          : [ "#00B880","","italic"],
    \   "xmlString"                             : [ "#32C5B0", "",  "italic"],
    \   "xmlTag"                                : ["#00B880", "",  "italic"],
    \   "xmlTagName"                            : [ "#009F6F","","italic"],
    \   "xmlValue"                              : [ "Navy", "#BDCA51",  "italic"],
    \ })
"
" Undercurl Colors: a few colors are set here, outside of the color dictionary  {{{1
highlight SpellRare            guifg=fg      guibg=bg     gui=undercurl guisp=#CCFFCC
highlight SpellLocal           guifg=fg      guibg=bg     gui=undercurl guisp=#75FF66
highlight SpellCap             guifg=#cc6666 guibg=bg     gui=undercurl guisp=#D200F7
highlight SpellBad             guifg=#cc6666 guibg=bg     gui=undercurl guisp=#EEAA11
highlight netrwList            guifg=#88CB35 guibg=bg     gui=undercurl guisp=SkyBlue2
highlight fountainSceneHeading guifg=#D6B883 guibg=Grey40 gui=undercurl guisp=SeaShell3
"
" Parameterized Highlight Settings: defaults highlights come after non-default ones {{{1
" Search Color: selection logic per global parameter Briofita_choice_for_search {{{2
" ------------------   SEARCH COLOR ------------------------------------------
if (g:Briofita_choice_for_search==1) 
    let g:Briofita_choice_for_search=0 " 0 and 1 equivalent: this may change in a future version
elseif (g:Briofita_choice_for_search==2) " search has a sort of dark-red background
    highlight DiffText gui=reverse,bold,underline guifg=#556B2F guibg=#E7F56B
    highlight Search gui=underline guifg=#E7F56B guibg=#AD2728
elseif (g:Briofita_choice_for_search==3) " search has a sort of light-(yellow/green) background
    highlight DiffText gui=bold,underline guifg=#AD2728 guibg=#e7f56b
    highlight Search gui=underline guifg=bg guibg=#9BA31C
elseif (g:Briofita_choice_for_search==4) " option 4: similar to 3 above, but brighter
    highlight DiffText gui=bold,underline guifg=#E7F56B guibg=#E22A37
    highlight Search gui=underline guifg=#556B2F guibg=#E7F56B
elseif (g:Briofita_choice_for_search==5) " search is just underlined rosy?tomato? text 
    highlight DiffText gui=bold,underline guifg=#AD2728 guibg=#e7f56b
    highlight Search gui=bold,underline   guifg=#FF88AA guibg=bg
else " any other setting: changed to default zero
    let g:Briofita_choice_for_search=0   " make it easier to create a rotation scheme
endif
if (g:Briofita_choice_for_search==0) " DEFAULT = search has a bright-red background
    highlight DiffText gui=reverse,bold,underline guifg=#556B2F guibg=#E7F56B
    highlight Search gui=underline guifg=#E7F56B guibg=#E22A37
endif
" 
" Normal Color: selection logic per global parameter Briofita_choice_for_normalcolor  {{{2
" ------------------   NORMAL COLOR ------------------------------------------
if g:Briofita_choice_for_normalcolor==1 " comes from moss colorscheme; sort of light-green
    highlight Normal guifg=PowderBlue guibg=#062926 gui=NONE
elseif g:Briofita_choice_for_normalcolor==2 " try when other options do not fit well with some weird syntax; golden?
    highlight Normal guifg=#D6B883 guibg=#062926 gui=NONE
else " any other setting: changed to default zero
    let g:Briofita_choice_for_normalcolor=0 " make it easier to create a rotation scheme
endif
if g:Briofita_choice_for_normalcolor==0 " DEFAULT
    highlight Normal guifg=#C6B6FE guibg=#062926 gui=NONE
endif
"
" CursorLineNr Color: selection logic per global parameter Briofita_choice_for_cursorlinenr  {{{2
" ------------------   CURSOR LINE NR COLOR ----------------------------------
if g:Briofita_choice_for_cursorlinenr==1 " yellow
    highlight CursorLineNr guifg=Yellow guibg=bg gui=bold
else " any other setting: changed to default zero
    let g:Briofita_choice_for_cursorlinenr=0 " make it easier to create a rotation scheme
endif
" NOTE code separation performed to have a uniform structure among all the branches (change?)
if g:Briofita_choice_for_cursorlinenr==0 " DEFAULT; orange
    highlight CursorLineNr guifg=Orange guibg=bg gui=bold
endif
"
" CursorLine And Cursorcolumn Colors: selection logic                     {{{2
" ------------------   CURSOR LINE + CURSOR COLUMN COLORS -----------------------------
let thecolor = s:Briofita_cursorcolors[0] " FIXME WBYL: exception in 'execute' below?
" FIXME hardcoded key constants ...
if (t:Briofita_choice_for_cursorline >= 1) && (t:Briofita_choice_for_cursorline <= 5)
    execute 'let thecolor = "'.s:Briofita_cursorcolors[t:Briofita_choice_for_cursorline].'"'
    execute "highlight CursorLine   gui=bold        guifg=NONE guibg=".thecolor
    execute "highlight CursorColumn gui=NONE        guifg=NONE guibg=".thecolor
elseif (t:Briofita_choice_for_cursorline == 6) || (t:Briofita_choice_for_cursorline == 7)
    " special: good READABILITY at the cost of showing NO SYNTAX: bold; white fg; colored bg
    execute 'let thecolor = "'.s:Briofita_cursorcolors[t:Briofita_choice_for_cursorline].'"'
    execute "highlight CursorLine   gui=bold guifg=white guibg=".thecolor
    execute "highlight CursorColumn gui=NONE        guifg=NONE guibg=".thecolor
elseif (t:Briofita_choice_for_cursorline == 8)
    " special: great READABILITY at the cost of showing NO SYNTAX: green fg; black bg; underline
    execute 'let thecolor = "'.s:Briofita_cursorcolors[8].'"'
    execute "highlight CursorLine   gui=underline guifg=green guibg=".thecolor
    execute "highlight CursorColumn gui=NONE        guifg=NONE guibg=".thecolor
else " any other setting: changed to default zero
    let t:Briofita_choice_for_cursorline=0 " make it easier to create a rotation scheme
endif
if (t:Briofita_choice_for_cursorline == 0) " DEFAULT 
    execute 'let thecolor = "'.s:Briofita_cursorcolors[0].'"'
    execute "highlight CursorLine   gui=bold        guifg=NONE guibg=".thecolor
    execute "highlight CursorColumn gui=NONE        guifg=NONE guibg=".thecolor
endif
"
" ColorColumn Color: selection logic per global parameter Briofita_choice_for_colorcolumn {{{2
" ------------------   COLOR COLUMN COLOR -------------------------------------
if g:Briofita_choice_for_colorcolumn!=3
    " choice == 3 means: color column was set before; a request not to change it at this point
    if g:Briofita_choice_for_colorcolumn==1
         " color column will use the same color as cursorlines if these in range [0...7]
         " FIXME hardcoded constants...
         if (t:Briofita_choice_for_cursorline >= 0) && (t:Briofita_choice_for_cursorline <= 7)
            execute 'let thecolor = "'.s:Briofita_cursorcolors[t:Briofita_choice_for_cursorline].'"'
            execute "highlight ColorColumn gui=NONE guifg=NONE  guibg=".thecolor
         else
            " make the color column almost invisible (ie make it == bg)
            highlight ColorColumn   gui=NONE guifg=NONE guibg=bg
         endif
    elseif g:Briofita_choice_for_colorcolumn==2
         " version 1.5.0: this background, which used to be 0, is now 2
         highlight ColorColumn gui=NONE guifg=NONE guibg=#004F4F
    else " any other setting: back to default zero
        let g:Briofita_choice_for_colorcolumn=0 " make it easier to create a rotation scheme
    endif
endif
if g:Briofita_choice_for_colorcolumn==0 " DEFAULT since ver.1.5.0
     " changed in version 1.5.0: number code for default, which used to be 2, is now 0
     highlight ColorColumn gui=NONE guifg=PaleGreen2 guibg=#294C44
endif

" No Distraction Mode: tab-parameter variable is tested here             {{{2
if exists("t:Briofita_no_distraction_mode") 
    " distractionless editing mode
    call g:BriofitaNoDistraction(t:Briofita_no_distraction_mode) 
endif

let &cpo = save_cpo

" ICursor: forced here to avoid a noxious hidden cursor I sometimes get with other colorschemes  {{{1
set guicursor+=i-ci:ver30-iCursor-blinkwait300-blinkon200-blinkoff150

" Modeline:  {{{1
"
" vim: filetype=vim tabstop=4 shiftwidth=4
" vim: foldmethod=marker foldlevel=0
