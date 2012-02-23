" IndGuide.vim
"   Author: Charles E. Campbell, Jr.
"   Date:   Feb 22, 2011
"   Version: 1b	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_IndGuidePlugin")
 finish
endif
let g:loaded_IndGuidePlugin = "v1b"
if !has("signs")
 echoerr 'Sorry, your vim is missing +signs; use  "configure --with-features=huge" , recompile, and install'
 finish
endif
let s:keepcpo= &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Public Interface: {{{1
com! -bang			IndGuide	call IndGuide#IndGuideCtrl(<bang>1)
sil! com -nargs=0	IG			call IndGuide#IndGuideToggle()

if has("gui_running") && has("menu") && &go =~# 'm'
 if !exists("g:DrChipTopLvlMenu")
  let g:DrChipTopLvlMenu= "DrChip."
 endif
 exe "menu ".g:DrChipTopLvlMenu."IndGuide.Start<tab>:IndGuide	:IndGuide<cr>"
endif
if !exists("b:indguidemode")
 let b:indguidemode= 0
endif

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
