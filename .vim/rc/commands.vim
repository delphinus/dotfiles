scriptencoding utf-8
command! SyntaxInfo call delphinus#syntax_info#get_info()

function! s:cleanUpStartUpTime() abort
  execute printf('silent! %%s,%s,$VIMRUNTIME,', expand('$VIMRUNTIME'))
  execute printf('silent! %%s,%s,$VIMRUNTIME,', resolve(expand('$VIMRUNTIME')))
  execute printf('silent! %%s,%s,$VIM,', expand('$VIM'))
  execute printf('silent! %%s,%s,$VIM,', resolve(expand('$VIM')))
  let vimrc = has('nvim') ? 'init.vim' : 'vimrc'
  let $INIT = '~/.cache/dein/.cache/' . vimrc . '/.dein'
  execute printf('silent! %%s,%s,$INIT,', expand($INIT))
  execute printf('silent! %%s,%s,$INIT,', substitute($INIT, '\~', '\\~', ''))
  let $CACHE = '~/.cache/dein/.cache'
  execute printf('silent! %%s,%s,$CACHE,', expand($CACHE))
  execute printf('silent! %%s,%s,$CACHE,', substitute($CACHE, '\~', '\\~', ''))
  let $DEIN = '~/.cache/dein'
  execute printf('silent! %%s,%s,$DEIN,', expand($DEIN))
  execute printf('silent! %%s,%s,$DEIN,', substitute($DEIN, '\~', '\\~', ''))
  execute printf('silent! %%s,%s,\~', expand('$HOME'))
endfunction

command! CleanUpStartUpTime call <SID>cleanUpStartUpTime()

" from denite.nvim
function! s:getchar() abort
  redraw | echo 'Press any key: '
  let c = getchar()
  while c ==# "\<CursorHold>"
    redraw | echo 'Press any key: '
    let c = getchar()
  endwhile
  redraw | echomsg printf('Raw: "%s" | Char: "%s"', c, nr2char(c))
endfunction
command! GetChar call s:getchar()
