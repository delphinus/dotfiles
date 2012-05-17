" QFixMemo 設定
if is_office_win
    let g:dropbox_dir='C:/Dropbox'
elseif is_office_cygwin
    let g:dropbox_dir='/c/Dropbox'
elseif is_remora
    let g:dropbox_dir='/Users/delphinus/Dropbox'
elseif is_backup
    let g:dropbox_dir='/home/delphinus/Dropbox'
endif

" キーマップリーダー
let QFixHowm_Key='g'
" ファイル保存用
if is_office_win || is_office_cygwin || is_remora || is_backup
    let howm_dir=g:dropbox_dir . '/Programming/howm'
elseif is_office
    let howm_dir=expand('$H') . '/howm'
endif

" ファイル名
let howm_filename='%Y/%m/%Y-%m-%d-%H%M%S.txt'
" ファイルのエンコーディング
let howm_fileencoding='utf-8'
" ファイルの改行コード
let howm_fileformat='dos'
" ファイル形式は howm_memo + markdown
let QFixHowm_FileType='howm_memo.markdown'
" ファイルの拡張子
let QFixHowm_FileExt='txt'
" 日記ファイル名
let QFixHowm_DiaryFile='%Y/%m/%Y-%m-%d-000000.txt'
" grep の指定
if is_office_win
    let mygrepprg='c:/cygwin/bin/grep.exe'
    let MyGrep_ShellEncoding='cp932'
elseif is_office || is_backup
    let mygrepprg='/bin/grep'
    let MyGrep_ShellEncoding='utf-8'
else
    let mygrepprg='/usr/bin/grep'
    let MyGrep_ShellEncoding='utf-8'
endif

" qfixmemo-calendar.vim をコピーしておく
let g:qfixmemo_plugin_dir = g:bundle_dir . '/qfixhowm'
let cp_cmd='cp'
if is_office_win
    let cp_cmd='copy'
endif
if !filereadable(g:qfixmemo_plugin_dir.'/plugin/qfixmemo-calendar.vim')
    let ret = system(cp_cmd . ' ' . g:qfixmemo_plugin_dir
                \ . '/misc/qfixmemo-calendar.vim '
                \ . g:qfixmemo_plugin_dir . '/plugin/')
endif

" calendar.vim--Matsumoto
let g:calendar_action='QFixMemoCalendarDiary'
let g:calendar_sign='QFixMemoCalendarSign'
let g:calendar_weeknm=1
let g:calendar_mruler='正月,如月,弥生,卯月,皐月,水無月'
            \ . ',文月,葉月,長月,神無月,霜月,師走'
let g:calendar_wruler='日 月 火 水 木 金 土'
let g:calendar_navi_label='先月,今月,来月'

" QfixMemo 保存前実行処理
" BufWritePre
function! QFixMemoBufWritePre()
  " タイトル行付加
  call qfixmemo#AddTitle()
  " タイムスタンプ付加
  call qfixmemo#AddTime()
  " タイムスタンプアップデート
  call qfixmemo#UpdateTime()
  " Wikiスタイルのキーワードリンク作成
  call qfixmemo#AddKeyword()
  " ファイル末の空行を削除
  call qfixmemo#DeleteNullLines()
endfunction

"-----------------------------------------------------------------------------
" 一つ分のエントリを選択
function! SelectOneEntry()
	" save cursor position
	let save_cursor = getpos('.')
	" save search pattern
	let save_search = @/

	JpJoinAll
	call search('^= ', 'b')
	let start = getpos('.')
	call search('\[\d\{4}-\d\d-\d\d \d\d:\d\d\]')
	let end = getpos('.')
	let lines = getline(start[1] + 1, end[1] - 1)
	let @" = join(lines, "\n")
	normal u

	" restore cursor position
	call setpos('.', save_cursor)
	" restore search pattern
	let @/ = save_search
endfunction

command! -nargs=0 SE :call SelectOneEntry()
