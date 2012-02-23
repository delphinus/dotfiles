" hicolors.vim:
"   Author:	Charles E. Campbell, Jr.
"   Date:	Aug 12, 2008
"  Usage:  :he hicolors
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
" GetLatestVimScripts: 1081 1 :AutoInstall: hicolors.vim
"
" History:
"  v5: Aug 12, 2008 hi link -> hi default link
"  v4: Sep 03, 2004 included SignColumn
"  v3: Sep 03, 2004 first release

" ---------------------------------------------------------------------
" Double-Loading handler: {{{1
if &cp || exists("s:loaded_syntax_hicolors")
 finish
endif
let s:loaded_syntax_hicolors= 1

" ---------------------------------------------------------------------
"  HighlightColors: {{{1
fun! s:HighlightColors()
  let curline= line(".")
  let curcol = col(".")
  if curline < 3
   let curline= 3
  endif
"  call Dfunc("HighlightColors() line=".curline." col=".curcol)
  setlocal updatetime=200
  set lz mouse+=n
  2
  norm! $

  " set up common syntax highlighting
  syn case match
  syn clear
  syn cluster hiColorGroup add=hiModeLine,hiHelp
  syn region hiColorLine start='^' end='$' contains=@hiColorGroup
  syn region hiModeLine  start='^\s*vim:' end='$'
  syn match hiHelp		"^\s*\zs\l.*$" contained
  hi default link hiColorLine	Ignore
  hi default link hiModeLine	Ignore
  hi default link hiHelp		Normal

  " set up syntax highlighting for listed groups.
  " Assumes that all colornames begin with a capital letter.
  while search('\<\%(\a\)','W') && line(".") < line("$")-4
   let color= expand("<cword>")
"   call Decho("color<".color.">")
   if s:HLTest(color)
    exe 'syn keyword hi'.color.' contained containedin=hiColorLine '.color
    exe 'hi default link hi'.color.' '.color
    exe 'syn cluster hiColorGroup add=hi'.color
   endif
  endwhile
  nohlsearch
  3
  exe "norm! z\<cr>"
  call cursor(curline,curcol)
  set nolz

"  if !exists("s:hlc_ctr")	"Decho
"   let s:hlc_ctr= 0	"Decho
"  endif	"Decho
"  let s:hlc_ctr= s:hlc_ctr + 1	"Decho
"  call Dret("HighlightColors : ".s:hlc_ctr)
endfun

" ---------------------------------------------------------------------
"  HLTest: test if highlighting group is defined {{{1
fun! s:HLTest(hlname)
"  call Dfunc("HLTest(hlname<".a:hlname.">)")
  let id_hlname= hlID(a:hlname)
  if id_hlname == 0
"   call Dret("HLTest 0 : id_hlname==0")
   return 0
  endif
  let id_trans = synIDtrans(id_hlname)
  if id_trans == 0
"   call Dret("HLTest 0 : id_trans==0")
   return 0
  endif
  let fg_hlname= synIDattr(id_trans,"fg")
  let bg_hlname= synIDattr(id_trans,"bg")
  let rvs      = synIDattr(id_trans,"reverse")
  let ul       = synIDattr(id_trans,"underline")
  let uc       = synIDattr(id_trans,"undercurl")
  let bold     = synIDattr(id_trans,"bold")
  if fg_hlname == "" && bg_hlname == "" && rvs == "" && ul == "" && uc == "" && bold == ""
"   call Decho("fg_hlname<".fg_hlname."> bg_hlname<".bg_hlname."> rvs=".rvs." ul=".ul." uc=".uc." bold=".bold)
   " OK, looks like its not a highlighting group.  One last test...
   try
   	exe "silent hi ".a:hlname
   catch /^Vim\%((\a\+)\)\=:E/
"    call Decho("HLTest 0 : ".a:hlname." not a highlighting group")
    return 0
   endtry
  endif
"   call Dret("HLTest 1")
  return 1
endfun

" ---------------------------------------------------------------------
"  Autocmd: {{{1
au CursorHold hicolors.txt set lz|call <SID>HighlightColors()|set nolz

" ---------------------------------------------------------------------
" Initialize: {{{1
call s:HighlightColors()

" ---------------------------------------------------------------------
" vim: fdm=marker
