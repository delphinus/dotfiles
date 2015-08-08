scriptencoding utf-8

function! delphinus#title#string() abort
  " 各種フラグ
  let modified = getbufvar('', '&mod') ? '+' : ''
  let readonly = getbufvar('', '&ro') ? '=' : ''
  let modifiable = getbufvar('', '&ma') ? '' : '-'
  let flag = modified . readonly . modifiable
  let flag = len(flag) ? ' ' . flag : ''
  " ホスト名
  let host = hostname() . ':'
  " ファイル名
  let filename = expand('%:t')
  " ファイル名がない場合
  let filename = len(filename) ? filename : 'NEW FILE'
  " $H が設定してある場合は、パス内を置換する
  let sub_home = len($H) ? ':s!' . $H . '!$H!' : ''
  let with_h_dir= expand('%:p' . sub_home . ':~:.:h')
  " カレントディレクトリからのパス
  let with_current_dir = expand('%:h')
  " 短い方を使う
  let dir = len(with_h_dir) < len(with_current_dir) ? with_h_dir : with_current_dir
  " dir を括弧で括る
  let dir = len(dir) && dir !=# '.' ? ' (' . dir . ')' : ''
  " 検索文字列
  let search_string = len(@/) ? ' [' . @/ . ']' : ''
  " 表示文字列を作成
  let str = filename . flag . dir . search_string
  " Screen などの時、タイトルバーに全角文字があったら化けるので対処する
  if !has('macunix') && !has('gui_running') && !len($TMUX)
    let str2 = ''
    for char in split(str, '\zs')
      if char2nr(char) > 255
        let str2 = str2 . '_'
      else
        let str2 = str2 . char
      endif
    endfor
    let str = str2
  endif
  return str
endfunction
