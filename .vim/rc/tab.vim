"-----------------------------------------------------------------------------
" タブバー設定
"-----------------------------------------------------------------------------

set tabline=%!MyTabLine()
function! MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'

    " the label is made by MyTabLabel()
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999XClose'
  endif

  return s
endfunction

function! MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  " SVN のホームディレクトリを消す
  let altbuf = substitute(bufname(buflist[winnr - 1]), '^/home/game/svn/game/', '', '')
  " $H や $HOME を消す
  if g:is_office || g:is_office_cygwin || g:is_remora
	let altbuf = substitute(altbuf, expand('$H/'), '', '')
	let altbuf = substitute(altbuf, expand('$HOME/'), '', '')
  elseif g:is_office_win
	let altbuf = substitute(altbuf, substitute(substitute(expand('$HOME\'), '^c:', '', ''), '\\', '\\\\', 'g'), '', '')
endif
  " ディレクトリ名を縮める
  "let altbuf = substitute(altbuf, '\v%(\/)@<=(.).{-}%(\/)@=', '\1', 'g')
  " 拡張子を取る
  "let altbuf = substitute(altbuf, '\v%([^/])@<=\.[^.]+$', '', '')
  " [ref] 対応
  let altbuf = substitute(altbuf, '\[ref-.*:\(.*\)\]', '[\1]', 'g')
  let altbuf = '|' . altbuf . '|'
  return altbuf
endfunction


