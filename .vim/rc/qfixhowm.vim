" QFixMemo 設定
let g:dropbox_dir = isdirectory('/mnt/hgfs') ? '/mnt/hgfs/Dropbox' : expand(g:home . '/Dropbox')

" キーマップリーダー
let QFixHowm_Key='g'
" ファイル保存用
if isdirectory(g:dropbox_dir)
  let howm_dir = g:dropbox_dir . '/Documents/howm'
else
  let howm_dir = expand('$H') . '/howm'
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
if executable('c:/cygwin/bin/grep.exe')
    let mygrepprg='c:/cygwin/bin/grep.exe'
    let MyGrep_cygwin17=1
elseif executable('/bin/grep')
    let mygrepprg='/bin/grep'
else
    let mygrepprg='/usr/bin/grep'
endif
" プレビュー無効
let g:QFix_PreviewEnable=0

" vim-markdown-quote-syntax 対応
augroup markdown_quote_syntax_for_howm_memo
  autocmd!
  autocmd Syntax howm_memo.markdown call markdown_quote_syntax#enable_quote_syntax()
augroup END

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

" カレンダーの休日予定
let QFixHowm_HolidayFile = neobundle#config#get('qfixhowm').path . '/misc/holiday/Sche-Hd-0000-00-00-000000.utf8'
" カレンダーの休日マークを隠す
highlight CalConceal ctermfg=8
" カレンダー表示の日本語化
let g:calendar_jp=2
" カレンダーの表示月数
let g:QFixHowm_CalendarCount=6

"-----------------------------------------------------------------------------
" 一つ分のエントリを選択
function! s:QFixSelectOneEntry()
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

noremap <silent> <Plug>(qfixhowm-select_one_entry) :<C-U>call <SID>QFixSelectOneEntry()<CR>
nmap g,S <Plug>(qfixhowm-select_one_entry)

"-----------------------------------------------------------------------------
" 一つ前と同じタイトルでエントリを作成
function! s:QFixCopyTitleFromPrevEntry()
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

noremap <silent> <Plug>(qfixhowm-copy_title_from_prev_entry) :<C-U>call <SID>QFixCopyTitleFromPrevEntry()<CR>
nmap g,M <Plug>(qfixhowm-copy_title_from_prev_entry)

"-----------------------------------------------------------------------------
" http://stackoverflow.com/questions/12325291/parse-a-date-in-vimscript
function! AdjustDate(date, offset)
    python <<EOP
import vim
import datetime

result = datetime.datetime.strptime(vim.eval('a:date'), '%Y-%m-%d') + \
    datetime.timedelta(days=int(vim.eval('a:offset')))
vim.command("let l:result = '" + result.strftime('%Y-%m-%d') + "'")
EOP

    return result
endfunction

" 日記移動
function! s:QFixMoveAroundDiaries(direction)
    let filename = expand('%:p:r')
    let ext = expand('%:e')
    let howm = g:howm_dir
    if has('win16') || has('win32') || has('win64')
        let filename = substitute(filename, '\\', '/', 'g')
        let howm = substitute(howm, '\\', '/', 'g')
    endif
    let ymd = matchstr(filename,
                \ '\c\v^' . howm . '/\d+/\d+/\zs\d+-\d+-\d+\ze-\d+$')
    if ymd == ''
        echom 'this is not qfixhowm file.'
        return
    endif

    let try_max = 30
    let new_filename = ''
    for try_count in range(1, try_max)
        let new_ymd = AdjustDate(ymd, try_count * a:direction)
        let new_date = matchlist(new_ymd, '\v(\d+)-(\d+)-\d+')
        let tmp_filename = printf('%s/%04d/%02d/%s-000000.%s',
                    \ g:howm_dir, new_date[1], new_date[2], new_ymd, ext)

        if filewritable(tmp_filename)
            let new_filename = tmp_filename
            break
        endif
    endfor

    if new_filename == ''
        echom 'diary is not found'
        return
    endif

    if &modified
        if exists('g:dwm_version')
            call DWM_New()
        else
            new
        endif
    endif

    execute 'edit ' . new_filename
endfunction

noremap <silent> <Plug>(qfixhowm-move_next_diary) :<C-U>call <SID>QFixMoveAroundDiaries(1)<CR>
nmap g,> <Plug>(qfixhowm-move_next_diary)
noremap <silent> <Plug>(qfixhowm-move_prev_diary) :<C-U>call <SID>QFixMoveAroundDiaries(-1)<CR>
nmap g,< <Plug>(qfixhowm-move_prev_diary)
execute 'autocmd FileType ' . QFixHowm_FileType . ' nmap ]] <Plug>(qfixhowm-move_next_diary)'
execute 'autocmd FileType ' . QFixHowm_FileType . ' nmap [[ <Plug>(qfixhowm-move_prev_diary)'

"-----------------------------------------------------------------------------
" 半角だけの行は整形しない
let JpFormatExclude = '^[^[[:print:][:space:]]\+$'

function! MarkdownToMail()
    %s/\t$//
    call <SID>QFixSelectOneEntry()
    call Yank2Remote(1)
    echo 'yank to remote for mail'
endfunction

nnoremap <Leader>ma :call MarkdownToMail()<CR>
