scriptencoding utf-8

function! delphinus#title#string() abort
  " 各種フラグ
  let l:modified = getbufvar('', '&mod') ? '+' : ''
  let l:readonly = getbufvar('', '&ro') ? '=' : ''
  let l:modifiable = getbufvar('', '&ma') ? '' : '-'
  let l:flag = l:modified . l:readonly . l:modifiable
  let l:flag = len(l:flag) ? ' ' . l:flag : ''
  " ホスト名
  let l:host = hostname() . ':'
  " ファイル名
  let l:filename = expand('%:t')
  " ファイル名がない場合
  let l:filename = len(l:filename) ? l:filename : 'NEW FILE'
  " $H が設定してある場合は、パス内を置換する
  let l:sub_home = len($H) ? ':s!' . $H . '!$H!' : ''
  let l:with_h_dir= expand('%:p' . l:sub_home . ':~:.:h')
  " カレントディレクトリからのパス
  let l:with_current_dir = expand('%:h')
  " 短い方を使う
  let l:dir = len(l:with_h_dir) < len(l:with_current_dir) ? l:with_h_dir : l:with_current_dir
  " dir を括弧で括る
  let l:dir = len(l:dir) && l:dir !=# '.' ? ' (' . l:dir . ')' : ''
  " 検索文字列
  let l:search_string = len(@/) ? ' [' . @/ . ']' : ''
  " 表示文字列を作成
  let l:str = l:filename . l:flag . l:dir . l:search_string
  " Screen などの時、タイトルバーに全角文字があったら化けるので対処する
  if !has('macunix') && !has('gui_running') && !len($TMUX)
    let l:str2 = ''
    for l:char in split(l:str, '\zs')
      if char2nr(l:char) > 255
        let l:str2 = l:str2 . '_'
      else
        let l:str2 = l:str2 . l:char
      endif
    endfor
    let l:str = l:str2
  endif
  return l:str
endfunction
