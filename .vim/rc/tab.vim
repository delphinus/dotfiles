"-----------------------------------------------------------------------------
" タブバー設定
"-----------------------------------------------------------------------------

set showtabline=2 " タブは常に表示

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

let g:use_Powerline_dividers = 1

function! MyTabLabel(n)
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    let altbuf = bufname(buflist[winnr - 1])
    " howm は特別
    if match(altbuf, '/howm/') > 0
        let altbuf = '[howm]'
    endif
    " $H や $HOME を消す
    if g:is_office || g:is_office_cygwin || g:is_remora
        " git のホームディレクトリを消す
        let altbuf = substitute(altbuf, 'git\(repos\)\?/[^/]*/\(app/\)\?', '', '')
        let my_home = substitute(expand('$H'), expand('$HOME/'), '', '')
        let altbuf = substitute(altbuf, my_home, '$H', '')
        let altbuf = substitute(altbuf, expand('$H/'), '$H', '')
        let altbuf = substitute(altbuf, expand('$HOME/'), '', '')
    elseif g:is_office_win
        let altbuf = substitute(altbuf, substitute(substitute(expand('$HOME\'), '^c:', '', ''), '\\', '\\\\', 'g'), '', '')
    endif
    " カレントタブ以外はパスを短くする
    if tabpagenr() != a:n
        let altbuf = substitute(altbuf, '^.*/', '', '')
        let altbuf = substitute(altbuf, '^.\zs.*\ze\.[^.]\+$', '', '')
    endif
    " [ref] 対応
    let altbuf = substitute(altbuf, '\[ref-.*:\(.*\)\]', '[\1]', 'g')
    if g:use_Powerline_dividers
        let dividers = g:Pl#Parser#Symbols[g:Powerline_symbols].dividers
        let left_div = nr2char(get(dividers[3], 0, 124))
        let right_div = nr2char(get(dividers[1], 0, 124))
        let altbuf = left_div . altbuf . right_div
    else
        let altbuf = '|' . altbuf . '|'
    endif
    " タブ番号を付加
    let altbuf = a:n . ':' . altbuf
    return altbuf
endfunction


