scriptencoding utf-8

function! delphinus#qfixhowm#init() abort
  " QFixMemo 設定
  let g:dropbox_dir = isdirectory('/mnt/hgfs') ? '/mnt/hgfs/Dropbox' : expand(g:home . '/Dropbox')

  " キーマップリーダー
  let g:QFixHowm_Key='g'
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

  " カレンダーの休日予定
  let g:QFixHowm_HolidayFile = dein#get('qfixhowm').path . '/misc/holiday/Sche-Hd-0000-00-00-000000.utf8'
  " カレンダーの休日マークを隠す
  highlight CalConceal ctermfg=8
  " カレンダー表示の日本語化
  let g:calendar_jp=2
  " カレンダーの表示月数
  let g:QFixHowm_CalendarCount=6
  " 半角だけの行は整形しない
  let g:JpFormatExclude = '^\([\x00-\xff]\+\|[\[#=].*\)$'
  " 連結マーカーを nbsp に設定
  let g:JpFormatMarker = ' '

  " 一つ分のエントリを選択
  noremap <silent> <Plug>(qfixhowm-select_one_entry) :<C-U>call delphinus#qfixhowm#select_one_entry()<CR>
  " 現在のエントリーを Gist に投稿する
  noremap <silent> <Plug>(qfixhowm-post_to_gist) :<C-U>call delphinus#qfixhowm#post_to_gist()<CR>
  " 一つ前と同じタイトルでエントリを作成
  noremap <silent> <Plug>(qfixhowm-copy_title_from_prev_entry) :<C-U>call delphinus#qfixhowm#copy_title_from_prev_entry()<CR>
  " 日記移動
  noremap <silent> <Plug>(qfixhowm-move_next_diary) :<C-U>call delphinus#qfixhowm#move_around_diaries(1)<CR>
  noremap <silent> <Plug>(qfixhowm-move_prev_diary) :<C-U>call delphinus#qfixhowm#move_around_diaries(-1)<CR>
  " 行末の \t を削除した上でエントリーをコピーする
  noremap <silent> <Plug>(qfixhowm-markdown_to_mail) :<C-U>call delphinus#qfixhowm#markdown_to_mail()<CR>

  execute 'autocmd FileType ' . g:QFixHowm_FileType . ' call delphinus#qfixhowm#set_mapping()'
endfunction

" マッピング
function! delphinus#qfixhowm#set_mapping() abort
  nmap <buffer> g,S <Plug>(qfixhowm-select_one_entry)
  nmap <buffer> g,G <Plug>(qfixhowm-post_to_gist)
  nmap <buffer> g,M <Plug>(qfixhowm-copy_title_from_prev_entry)
  nmap <buffer> g,> <Plug>(qfixhowm-move_next_diary)
  nmap <buffer> g,< <Plug>(qfixhowm-move_prev_diary)
  nmap <buffer> ]] <Plug>(qfixhowm-move_next_diary)
  nmap <buffer> [[ <Plug>(qfixhowm-move_prev_diary)
  nmap <buffer> <Leader>ma <Plug>(qfixhowm-markdown_to_mail)

  " JpFormat.vim
  " 現在行を整形
  nnoremap <buffer> <silent> gl :JpFormat<CR>
  " 現在行が整形対象外でも強制的に整形
  nnoremap <buffer> <silent> gL :JpFormat!<CR>
  " 自動整形のON/OFF切替
  nnoremap <buffer> <silent> g. :JpFormatToggle<CR>
  " カーソル位置の分割行をまとめてヤンク
  nnoremap <buffer> <silent> gY :JpYank<CR>
  " カーソル位置の分割行をまとめて連結
  nnoremap <buffer> <silent> gJ :JpJoin<CR>
  " 整形に gqを使うかどうかをトグルする
  nnoremap <buffer> <silent> gC :JpFormatGqToggle<CR>
  " 外部ビューアを起動する
  nnoremap <buffer> <silent> <F8> :JpExtViewer<CR>

  call JpSetAutoFormat()
endfunction

" 現在のエントリーの開始行・終了行を返す
function! delphinus#qfixhowm#current_entry_line_number(...) abort
  let l:to_join = 0
  if a:0 == 1 && a:1
    let l:to_join = 1
  endif

  " save cursor position
  let l:save_cursor = getpos('.')

  if l:to_join
    JpJoinAll
  endif

  call QFixMRUMoveCursor('prev')
  let l:start = getpos('.')
  call QFixMRUMoveCursor('next')
  let l:end = getpos('.')

  if l:to_join
    normal! u
  endif

  " restore cursor position
  call setpos('.', l:save_cursor)

  return [l:start[1] + 1, l:end[1] - 2]
endfunction

" 一つ分のエントリーを選択
function! delphinus#qfixhowm#select_one_entry() abort
  let l:numbers = delphinus#qfixhowm#current_entry_line_number(1)
  let l:lines = getline(l:numbers[0], l:numbers[1])
  let @* = join(l:lines, "\n")
endfunction

" 現在のエントリーを Gist に投稿する
let s:extension_map = {
      \ 'perl': 'pl',
      \ 'ruby': 'rb',
      \ 'python': 'py',
      \ 'javascript': 'js',
      \ 'typescript': 'ts',
      \ }

function! delphinus#qfixhowm#post_to_gist() abort
  let [l:start_line, l:end_line] = delphinus#qfixhowm#current_entry_line_number()
  let l:title = matchstr(getline(l:start_line - 1), g:qfixmemo_title . '\s*\zs.*')
  let l:filename = expand('%:t')
  let l:new_filename = ''
  if getline(l:start_line) =~# '^```\S*$' && getline(l:end_line) =~# '^```$'
    let l:file_type = matchstr(getline(l:start_line), '^```\zs\S\+')
    let l:start_line += 1
    let l:end_line -= 1
    if len(l:file_type) > 0
      let l:ext = get(s:extension_map, l:file_type, l:file_type)
      let l:current_ext = '.' . expand('%:e')
      if ! empty(l:ext) && l:ext !=? l:current_ext
        let l:new_filename = expand('%:t:r') . '.' . l:ext
      endif
    endif
  else
    let l:new_filename = expand('%:t:r') . '.markdown'
  endif

  echom printf('%d,%dGista post --description="%s"', l:start_line, l:end_line, l:title)
  execute printf('%d,%dGista post --description="%s"', l:start_line, l:end_line, l:title)
endfunction

" 一つ前と同じタイトルでエントリーを作成
function! delphinus#qfixhowm#copy_title_from_prev_entry() abort
    let l:save_register = @"

    call QFixMRUMoveCursor('prev')
    let l:title = getline('.')
    let l:title = substitute(l:title, '^= ', '', '')
    let @" = l:title
    call QFixMRUMoveCursor('next')
    call qfixmemo#Template('next')
    stopinsert
    normal! p
    normal! o
    startinsert

    let @" = l:save_register
endfunction

" 日記移動
function! delphinus#qfixhowm#move_around_diaries(direction) abort
    let l:filename = expand('%:p:r')
    let l:ext = expand('%:e')
    let l:howm = g:howm_dir
    if has('win16') || has('win32') || has('win64')
        let l:filename = substitute(l:filename, '\\', '/', 'g')
        let l:howm = substitute(l:howm, '\\', '/', 'g')
    endif
    let l:ymd = matchstr(l:filename,
                \ '\c\v^' . l:howm . '/\d+/\d+/\zs\d+-\d+-\d+\ze-\d+$')
    if l:ymd ==# ''
        echom 'this is not qfixhowm file.'
        return
    endif

    let l:try_max = 30
    let l:new_filename = ''
    for l:try_count in range(1, l:try_max)
        let l:new_ymd = delphinus#datetime#adjust_date(l:ymd, l:try_count * a:direction)
        let l:new_date = matchlist(l:new_ymd, '\v(\d+)-(\d+)-\d+')
        let l:tmp_filename = printf('%s/%04d/%02d/%s-000000.%s',
                    \ g:howm_dir, l:new_date[1], l:new_date[2], l:new_ymd, l:ext)

        if filewritable(l:tmp_filename)
            let l:new_filename = l:tmp_filename
            break
        endif
    endfor

    if l:new_filename ==# ''
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

    execute 'edit ' . l:new_filename
endfunction

" 行末の \t を削除した上でエントリーをコピーする
function! delphinus#qfixhowm#markdown_to_mail() abort
  execute '%s/\t$//'
  call delphinus#qfixhowm#select_one_entry()
  echo 'yank to remote for mail'
endfunction
