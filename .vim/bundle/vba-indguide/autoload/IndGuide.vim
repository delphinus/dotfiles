" IndGuide.vim
"   Author: Charles E. Campbell, Jr.
"   Date:   Feb 22, 2012
"   Version: 1b	ASTRO-ONLY
"   Phillippians 1:27 :  Only let your manner of life be worthy of the gospel of
"     Christ, that, whether I come and see you or am absent, I may hear of
"     your state, that you stand firm in one spirit, with one soul striving
"     for the faith of the gospel
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_IndGuide")
 finish
endif
let g:loaded_IndGuide = "v1b"
if v:version < 700
 echohl WarningMsg
 echo "***warning*** this version of IndGuide needs vim 7.0"
 echohl Normal
 finish
endif
if !has("signs")
 echoerr 'Sorry, your vim is missing +signs; use  "configure --with-features=huge" , recompile, and install'
 finish
endif
if !has("syntax")
 echoerr 'Sorry, your vim is missing +syntax; use  "configure --with-features=huge" , recompile, and install'
 finish
endif
let s:keepcpo= &cpo
set cpo&vim
"DechoRemOn

" ---------------------------------------------------------------------
"  Parameters: {{{1
let s:INDGUIDE= 2683
if !exists("g:DrChipTopLvlMenu")
 let g:DrChipTopLvlMenu= "DrChip."
endif

" ---------------------------------------------------------------------
" Guide Characters: {{{1
if exists("g:indguide_more") | let s:indguide_more= g:indguide_more | else | let s:indguide_more = '⍈' | endif
if exists("g:indguide_stay") | let s:indguide_stay= g:indguide_stay | else | let s:indguide_stay = '│' | endif
if exists("g:indguide_less") | let s:indguide_less= g:indguide_less | else | let s:indguide_less = '├' | endif
if exists("g:indguide_stop") | let s:indguide_stop= g:indguide_stop | else | let s:indguide_stop = '└' | endif

" =====================================================================
"  Functions: {{{1

" ---------------------------------------------------------------------
" s:IndGuide: {{{2
fun! s:IndGuide(mode,...)
"  call Dfunc("s:IndGuide(mode=".a:mode.((a:0 > 0)? " ".a:1.")" : ")"))

  if a:mode == 1
   " initial placement of signs
"   call Decho("mode ".a:mode.": initial sign placement")
   let wt = line("w0") " window top line
   let wc = line(".")  " window current line
   let wb = line("w$") " window bottom line
   let fb = line("$")  " file bottom line
"   call Decho("initial placement of signs: wt=".wt." wc=".wc." wb=".wb." fb=".fb)
   let w                                = wt
   let s:indguide_topline_{bufnr("%")}  = wt
   let s:indguide_curline_{bufnr("%")}  = wc
   let s:indguide_wbotline_{bufnr("%")} = wb
   let s:indguide_botline_{bufnr("%")}  = fb
"   call Decho("init s:indguide_curline_".bufnr("%")."=".s:indguide_curline_{bufnr("%")})
"   call Decho("init s:indguide_topline_".bufnr("%")."=".s:indguide_topline_{bufnr("%")})
"   call Decho("init s:indguide_wbotline_".bufnr("%")."=".s:indguide_wbotline_{bufnr("%")})
"   call Decho("init s:indguide_botline_".bufnr("%")."=".s:indguide_botline_{bufnr("%")})
   let s:igid_{bufnr("%")}= s:INDGUIDE
   while w <= wb
	if foldclosed(w) != -1
	 let w= foldclosedend(w)+1
	 continue
	endif
	let prvind = (w > 1)? indent(prevnonblank(w-1)) : 0
	let curind = indent(prevnonblank(w))
	let nxtind = (w <= line("$"))? indent(nextnonblank(w+1)) : 0
	if getline(w) =~ '^\s*$'
"	 call Decho("indents: prv=".prvind." cur=".curind." nxt=".nxtind." blank : ".getline(w))
    elseif curind < nxtind
	 exe "sign place ".(s:igid_{bufnr("%")})." line=".w." name=INDGUIDE_MORE buffer=".bufnr("%")
"	 call Decho("indents: prv=".prvind." cur=".curind." nxt=".nxtind." more  : ".getline(w))
	elseif curind > nxtind && nxtind == 0
	 exe "sign place ".(s:igid_{bufnr("%")})." line=".w." name=INDGUIDE_STOP buffer=".bufnr("%")
"	 call Decho("indents: prv=".prvind." cur=".curind." nxt=".nxtind." stop  : ".getline(w))
	elseif curind >= prvind
	 exe "sign place ".(s:igid_{bufnr("%")})." line=".w." name=INDGUIDE_STAY buffer=".bufnr("%")
"	 call Decho("indents: prv=".prvind." cur=".curind." nxt=".nxtind." stay  : ".getline(w))
	elseif curind < prvind
	 exe "sign place ".(s:igid_{bufnr("%")})." line=".w." name=INDGUIDE_LESS buffer=".bufnr("%")
"	 call Decho("indents: prv=".prvind." cur=".curind." nxt=".nxtind." less  : ".getline(w))
	endif
	let w      = w + 1
	let s:igid_{bufnr("%")} = s:igid_{bufnr("%")} + 1
   endwhile

  elseif a:mode == 2
"   call Decho("mode ".a:mode.": consider removing and placing signs")
   if exists("s:indguide_curline_{bufnr('%')}")
"	call Decho("line(.)=".line("."))
"	call Decho("s:indguide_curline_".bufnr("%")."=".s:indguide_curline_{bufnr("%")})
"	call Decho("line(w0)=".line("w0"))
"	call Decho("s:indguide_topline_".bufnr("%")."=".s:indguide_topline_{bufnr("%")})
"	call Decho("line(w$)=".line("w$"))
"	call Decho("s:indguide_wbotline_".bufnr("%")."=".s:indguide_wbotline_{bufnr("%")})
"	call Decho("line($)=".line("$"))
"	call Decho("s:indguide_botline_".bufnr("%")."=".s:indguide_botline_{bufnr("%")})
    " remove and place signs
	if line(".") != s:indguide_curline_{bufnr("%")} || line("w0") != s:indguide_topline_{bufnr("%")} || line("w$") != s:indguide_wbotline_{bufnr("%")} || line("$") != s:indguide_botline_{bufnr("%")}
     let lzkeep= &lz
	 set lz
     call s:IndGuide(3)  " remove signs
     call s:IndGuide(1)  " place signs
     let &lz= lzkeep
    endif
   endif

  elseif a:mode == 3
   " removal of signs
"   call Decho("mode ".a:mode.": removal of signs")
   if exists("s:igid_".bufnr("%"))
    let igid= s:INDGUIDE
    while igid < s:igid_{bufnr("%")}
     exe "sil! sign unplace ".(igid)." buffer=".bufnr("%")
"     call Decho("exe "."sil! sign unplace ".(igid)." buffer=".bufnr("%"))
     let igid= igid + 1
    endwhile
    exe "menu ".g:DrChipTopLvlMenu."IndGuide.Start<tab>:IndGuide	:IndGuide<cr>"
    exe 'silent! unmenu '.g:DrChipTopLvlMenu.'IndGuide.Stop'
    unlet s:igid_{bufnr("%")}
   endif

  else
   echoerr "mode=".a:mode." unsupported"
  endif

"  call Dret("s:IndGuide")
endfun

" ---------------------------------------------------------------------
" IndGuide#IndGuideCtrl: {{{2
fun! IndGuide#IndGuideCtrl(start)
"  call Dfunc("IndGuide#IndGuideCtrl(start=".a:start.")")

  if      a:start && !exists("s:indguide_{bufnr('%')}")
   let s:indguide_{bufnr("%")}= 1
   let b:indguidemode         = 1

   if !exists("s:indguide_signs")
	let s:indguide_signs= 1
	hi default HL_IndGuide gui=none ctermfg=gray ctermbg=black guifg=gray50 guibg=black
	silent call s:AvoidOtherSigns()
	exe 'sign define INDGUIDE_MORE text='.(s:indguide_more).' texthl=HL_IndGuide'
	exe 'sign define INDGUIDE_STAY text='.(s:indguide_stay).' texthl=HL_IndGuide'
	exe 'sign define INDGUIDE_LESS text='.(s:indguide_less).' texthl=HL_IndGuide'
	exe 'sign define INDGUIDE_STOP text='.(s:indguide_stop).' texthl=HL_IndGuide'
   endif

   exe "menu ".g:DrChipTopLvlMenu."IndGuide.Stop<tab>:IndGuide!	:IndGuide!<cr>"
   exe 'silent! unmenu '.g:DrChipTopLvlMenu.'IndGuide.Start'
   call s:IndGuide(1)
"   call Decho("set up all IndGuideAutoCmd automcmds")
   augroup IndGuideAutoCmd
	au!
    au CursorHold           * call <SID>IndGuide(2,"cursorhold")
	au CursorMoved          * call <SID>IndGuide(2,"cursormoved")
	au FileChangedShellPost * call <SID>IndGuide(2,"filechangedshellpost")
	au FocusGained          * call <SID>IndGuide(2,"focusgained")
	au FocusLost            * call <SID>IndGuide(2,"focuslost")
	au InsertEnter          * call <SID>IndGuide(2,"insertenter")
	au ShellCmdPost         * call <SID>IndGuide(2,"shellcmdpost")
	au ShellFilterPost      * call <SID>IndGuide(2,"shellfilterpost")
	au TabEnter             * call <SID>IndGuide(2,"tabenter")
	au VimResized           * call <SID>IndGuide(2,"vimresized")
	au WinEnter             * call <SID>IndGuide(2,"winenter")
    au ColorScheme          * call <SID>ColorschemeLoaded()
   augroup END

  elseif !a:start && exists("s:indguide_{bufnr('%')}")
   let b:indguidemode         = 0
   unlet s:indguide_{bufnr("%")}
"   call Decho("clear all autocmds from IndGuideAutoCmd group")
   augroup IndGuideAutoCmd
	au!
   augroup END
   augroup! IndGuideAutoCmd
   call s:IndGuide(3)
   exe "sign unplace ".(s:INDGUIDE+0)." buffer=".bufnr("%")
   exe "sign unplace ".(s:INDGUIDE+1)." buffer=".bufnr("%")
   exe "sign unplace ".(s:INDGUIDE+2)." buffer=".bufnr("%")
   exe "sign unplace ".(s:INDGUIDE+3)." buffer=".bufnr("%")
   exe "menu ".g:DrChipTopLvlMenu."IndGuide.Start<tab>:IndGuide	:IndGuide<cr>"
   exe 'silent! unmenu '.g:DrChipTopLvlMenu.'IndGuide.Stop'

  else
   echo "IndGuide is already ".((a:start)? "enabled" : "off")
  endif
"  call Dret("IndGuide#IndGuideCtrl")
endfun

" ---------------------------------------------------------------------
" IndGuide#IndGuideToggle: supports the :IG command for quick indent-guide-mode toggling {{{2
"                          If the :IG command is already available, then it will not be overridden.
fun! IndGuide#IndGuideToggle()
"  call Dfunc("IndGuide#IndGuideToggle()")
  
  if !exists("b:indguidemode")
   let b:indguidemode= 0
  endif
  if b:indguidemode == 0
   IndGuide
  else
   IndGuide!
  endif

"  call Dret("IndGuide#IndGuideToggle")
endfun

" ---------------------------------------------------------------------
" s:ColorschemeLoaded: {{{2
fun! s:ColorschemeLoaded()
"  call Dfunc("s:ColorschemeLoaded()")
	hi default HL_IndGuide gui=none ctermfg=gray ctermbg=black guifg=gray50 guibg=black
"  call Dret("s:ColorschemeLoaded")
endfun

" ---------------------------------------------------------------------
" s:AvoidOtherSigns: {{{2
fun! s:AvoidOtherSigns()
"  call Dfunc("s:AvoidOtherSigns()")
  if !exists("s:othersigns")
   " only do this one time
   redir => s:othersigns
    sign place
   redir END
   " determine the max id being used and use one more than that as the beginning of IndGuide ids
   let signlist= split(s:othersigns,'\n')
   let idlist  = map(signlist,"substitute(v:val,'^.\\{-}\\<id=\\(\\d\\+\\)\\s.*$','\\1','')")
   if len(idlist) > 2
    let idlist = remove(idlist,2,-1)
    let idlist = map(idlist,"str2nr(v:val)")
    let idmax  = max(idlist)
	if idmax > s:INDGUIDE
	 let s:INDGUIDE = idmax + 1
"     call Decho("s:INDGUIDE=".s:INDGUIDE)
	endif
   endif
   unlet s:othersigns
   let s:othersigns= 1
   endif
"  call Dret("s:AvoidOtherSigns : s:INDGUIDE=".s:INDGUIDE)
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
