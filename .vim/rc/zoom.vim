" zoom.vim : 「+」、「-」キーで文字の大きさを変更 — 名無しのvim使い
" http://nanasi.jp/articles/vim/zoom_vim.html
" https://raw.github.com/taku-o/downloads/master/zoom.vim

scriptencoding utf-8
if &cp || exists("g:loaded_zoom")
    finish
endif
let g:loaded_zoom = 1

let s:save_cpo = &cpo
set cpo&vim

" keep default value
let s:current_font = &guifont

" command
command! -narg=0 ZoomIn    :call s:ZoomIn()
command! -narg=0 ZoomOut   :call s:ZoomOut()
command! -narg=0 ZoomReset :call s:ZoomReset()

" map
nmap + :ZoomIn<CR>
nmap - :ZoomOut<CR>

" guifont size + 1
function! s:ZoomIn()
  let l:fsize = substitute(&guifont, '^.*:h\([^:]*\).*$', '\1', '')
  let l:fsize += 1
  let l:guifont = substitute(&guifont, ':h\([^:]*\)', ':h' . l:fsize, '')
  let &guifont = l:guifont
endfunction

" guifont size - 1
function! s:ZoomOut()
  let l:fsize = substitute(&guifont, '^.*:h\([^:]*\).*$', '\1', '')
  let l:fsize -= 1
  let l:guifont = substitute(&guifont, ':h\([^:]*\)', ':h' . l:fsize, '')
  let &guifont = l:guifont
endfunction

" reset guifont size
function! s:ZoomReset()
  let &guifont = s:current_font
endfunction

let &cpo = s:save_cpo
finish

==============================================================================
zoom.vim : 文字サイズコントロールスクリプト
------------------------------------------------------------------------------
$VIMRUNTIMEPATH/plugin/zoom.vim
==============================================================================
author  : 小見 拓
url     : http://nanasi.jp/
email   : mail@nanasi.jp
version : 2009/12/19 16:00:00
==============================================================================
文字のサイズを拡大、縮小するスクリプト。

------------------------------------------------------------------------------
" 文字サイズ拡大
:ZoomIn

" 文字サイズ縮小
:ZoomOut

" 変更した文字サイズを元に戻す
:ZoomReset


------------------------------------------------------------------------------
他のアプリケーションに合わせて、+、-にマッピングをセットしてあります。

" 文字サイズ拡大
+

" 文字サイズ縮小
-

==============================================================================
" vim: set et ft=vim nowrap :
