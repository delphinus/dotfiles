function! GetTitleString()
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
    " 'svn/game/' を消す
    let dir = substitute(dir, 'svn/game/', '', '')
    " dir を括弧で括る
    let dir = len(dir) && dir != '.' ? ' (' . dir . ')' : ''
    " 検索文字列
    let search_string = len(@/) ? ' [' . @/ . ']' : ''
    " 表示文字列を作成
    "let str = g:is_remora_air2 ? filename : host . filename . flag . dir . search_string
    let str = host . filename . flag . dir . search_string
    " Screen などの時、タイトルバーに 2 バイト文字があったら化けるので対処する
    if !has('gui_running')
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

" タイトル文字列指定
set titlestring=%{GetTitleString()}

" ウィンドウタイトルを更新する
if &term =~ '^screen'
    set t_ts=k
    set t_fs=\
endif
if has('gui_running') || &term =~ '^screen' || &term =~ '^xterm'
    set title
endif

" Vim が終了したらこのタイトルにする
set titleold=bash
