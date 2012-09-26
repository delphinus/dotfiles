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
    let dir = expand('%:p' . sub_home . ':~:.:h')
    " 'svn/game/' を消す
    let dir = substitute(dir, 'svn/game/', '', '')
    " dir を括弧で括る
    let dir = len(dir) && dir != '.' ? ' (' . dir . ')' : ''
    " 表示文字列を作成
    let str = host . filename . flag . dir
    " win32 の時、タイトルバーに 2 バイト文字があったら化けるので対処する
    if !has('win32')
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
if &term =~ '^screen'
    set t_ts=k
    set t_fs=\
endif
" ウィンドウタイトルを更新する
if &term =~ '^screen' || &term =~ '^xterm'
    set title
endif

