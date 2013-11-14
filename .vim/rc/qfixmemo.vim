" QFixMemo 設定
if is_xerxes
    let g:dropbox_dir='D:/Dropbox'
elseif is_xerxes_cygwin
    let g:dropbox_dir='/d/Dropbox'
elseif is_office_win
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
    let howm_dir=g:dropbox_dir . '/Documents/howm'
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

	JpJoinAll
	call QFixMRUMoveCursor('prev')
	let start = getpos('.')
	call QFixMRUMoveCursor('next')
	let end = getpos('.')
	let lines = getline(start[1] + 1, end[1] - 2)
	let @" = join(lines, "\n")
	normal u

	" restore cursor position
	call setpos('.', save_cursor)
endfunction

command! -nargs=0 SE :call SelectOneEntry()

"-----------------------------------------------------------------------------
" 一つ前と同じタイトルでエントリを作成
function! CopyTitleFromPrevEntry()
	let save_register = @"

	call QFixMRUMoveCursor('prev')
	let title = getline('.')
	let title = substitute(title, '^= ', '', '')
	let @" = title
	call QFixMRUMoveCursor('next')
	call qfixmemo#Template('next')
	stopinsert
	normal! p
	normal! o
	startinsert

	let @" = save_register
endfunction

nnoremap g,M :<C-U>call CopyTitleFromPrevEntry()<CR>

"-----------------------------------------------------------------------------
" 半角だけの行は整形しない
let JpFormatExclude = '^[^[[:print:][:space:]]\+$'
