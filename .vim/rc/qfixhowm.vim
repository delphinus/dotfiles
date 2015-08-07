scriptencoding utf-8
" QFixMemo 設定
let g:dropbox_dir = isdirectory('/mnt/hgfs') ? '/mnt/hgfs/Dropbox' : expand(g:home . '/Dropbox')

" キーマップリーダー
let QFixHowm_Key='g'
" ファイル保存用
if isdirectory(g:dropbox_dir)
  let g:howm_dir = g:dropbox_dir . '/Documents/howm'
else
  let g:howm_dir = expand('$H') . '/howm'
endif

" ファイル名
let g:howm_filename='%Y/%m/%Y-%m-%d-%H%M%S.txt'
" ファイルのエンコーディング
let g:howm_fileencoding='utf-8'
" ファイルの改行コード
let g:howm_fileformat='dos'
" ファイル形式は howm_memo + markdown
let g:QFixHowm_FileType='howm_memo.markdown'
" ファイルの拡張子
let g:QFixHowm_FileExt='txt'
" 日記ファイル名
let g:QFixHowm_DiaryFile='%Y/%m/%Y-%m-%d-000000.txt'
" grep の指定
if executable('c:/cygwin/bin/grep.exe')
    let g:mygrepprg='c:/cygwin/bin/grep.exe'
    let g:MyGrep_cygwin17=1
elseif executable('/bin/grep')
    let g:mygrepprg='/bin/grep'
else
    let g:mygrepprg='/usr/bin/grep'
endif
" プレビュー無効
let g:QFix_PreviewEnable=0

" vim-markdown-quote-syntax 対応
augroup markdown_quote_syntax_for_howm_memo
  autocmd!
  autocmd Syntax howm_memo.markdown call markdown_quote_syntax#enable_quote_syntax()
augroup END

" カレンダーの休日予定
let g:QFixHowm_HolidayFile = neobundle#config#get('qfixhowm').path . '/misc/holiday/Sche-Hd-0000-00-00-000000.utf8'
" カレンダーの休日マークを隠す
highlight CalConceal ctermfg=8
" カレンダー表示の日本語化
let g:calendar_jp=2
" カレンダーの表示月数
let g:QFixHowm_CalendarCount=6
" 半角だけの行は整形しない
let JpFormatExclude = '^[^[[:print:][:space:]]\+$'

"-----------------------------------------------------------------------------
" 一つ分のエントリを選択
noremap <silent> <Plug>(qfixhowm-select_one_entry) :<C-U>call delphinus#qfixhowm#select_one_entry()<CR>
nmap g,S <Plug>(qfixhowm-select_one_entry)

"-----------------------------------------------------------------------------
" 現在のエントリーを Gist に投稿する
noremap <silent> <Plug>(qfixhowm-post_to_gist) :<C-U>call delphinus#qfixhowm#post_to_gist()<CR>
nmap g,G <Plug>(qfixhowm-post_to_gist)

"-----------------------------------------------------------------------------
" 一つ前と同じタイトルでエントリを作成
noremap <silent> <Plug>(qfixhowm-copy_title_from_prev_entry) :<C-U>call delphinus#qfixhowm#copy_title_from_prev_entry()<CR>
nmap g,M <Plug>(qfixhowm-copy_title_from_prev_entry)

"-----------------------------------------------------------------------------
" 日記移動
noremap <silent> <Plug>(qfixhowm-move_next_diary) :<C-U>call delphinus#qfixhowm#move_around_diaries(1)<CR>
noremap <silent> <Plug>(qfixhowm-move_prev_diary) :<C-U>call delphinus#qfixhowm#move_around_diaries(-1)<CR>
nmap g,> <Plug>(qfixhowm-move_next_diary)
nmap g,< <Plug>(qfixhowm-move_prev_diary)
execute 'autocmd FileType ' . QFixHowm_FileType . ' nmap ]] <Plug>(qfixhowm-move_next_diary)'
execute 'autocmd FileType ' . QFixHowm_FileType . ' nmap [[ <Plug>(qfixhowm-move_prev_diary)'

"-----------------------------------------------------------------------------
" 行末の \t を削除した上でエントリーをコピーする
noremap <silent> <Plug>(qfixhowm-markdown_to_mail) :<C-U>call delphinus#qfixhowm#markdown_to_mail()<CR>
nmap <Leader>ma <Plug>(qfixhowm-markdown_to_mail)
