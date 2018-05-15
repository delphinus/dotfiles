scriptencoding utf-8

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
  let to_join = 0
  if a:0 == 1 && a:1
    let to_join = 1
  endif

  " save cursor position
  let save_cursor = getpos('.')

  if to_join
    JpJoinAll
  endif

  call QFixMRUMoveCursor('prev')
  let start = getpos('.')
  call QFixMRUMoveCursor('next')
  let end = getpos('.')

  if to_join
    normal! u
  endif

  " restore cursor position
  call setpos('.', save_cursor)

  return [start[1] + 1, end[1] - 2]
endfunction

" 一つ分のエントリーを選択
function! delphinus#qfixhowm#select_one_entry() abort
  let numbers = delphinus#qfixhowm#current_entry_line_number(1)
  let lines = getline(numbers[0], numbers[1])
  let @* = join(lines, "\n")
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
  let [start_line, end_line] = delphinus#qfixhowm#current_entry_line_number()
  let title = matchstr(getline(start_line - 1), g:qfixmemo_title . '\s*\zs.*')
  let filename = expand('%:t')
  let new_filename = ''
  if getline(start_line) =~# '^```\S*$' && getline(end_line) =~# '^```$'
    let file_type = matchstr(getline(start_line), '^```\zs\S\+')
    let start_line += 1
    let end_line -= 1
    if len(file_type) > 0
      let ext = get(s:extension_map, file_type, file_type)
      let current_ext = '.' . expand('%:e')
      if ! empty(ext) && ext !=? current_ext
        let new_filename = expand('%:t:r') . '.' . ext
      endif
    endif
  else
    let new_filename = expand('%:t:r') . '.markdown'
  endif

  echom printf('%d,%dGista post --description="%s"', start_line, end_line, title)
  execute printf('%d,%dGista post --description="%s"', start_line, end_line, title)
endfunction

" 一つ前と同じタイトルでエントリーを作成
function! delphinus#qfixhowm#copy_title_from_prev_entry() abort
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

" 日記移動
function! delphinus#qfixhowm#move_around_diaries(direction) abort
    let filename = expand('%:p:r')
    let ext = expand('%:e')
    let howm = g:howm_dir
    if has('win16') || has('win32') || has('win64')
        let filename = substitute(filename, '\\', '/', 'g')
        let howm = substitute(howm, '\\', '/', 'g')
    endif
    let ymd = matchstr(filename,
                \ '\c\v^' . howm . '/\d+/\d+/\zs\d+-\d+-\d+\ze-\d+$')
    if ymd ==# ''
        echom 'this is not qfixhowm file.'
        return
    endif

    let try_max = 30
    let new_filename = ''
    for try_count in range(1, try_max)
        let new_ymd = delphinus#datetime#adjust_date(ymd, try_count * a:direction)
        let new_date = matchlist(new_ymd, '\v(\d+)-(\d+)-\d+')
        let tmp_filename = printf('%s/%04d/%02d/%s-000000.%s',
                    \ g:howm_dir, new_date[1], new_date[2], new_ymd, ext)

        if filewritable(tmp_filename)
            let new_filename = tmp_filename
            break
        endif
    endfor

    if new_filename ==# ''
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

" 行末の \t を削除した上でエントリーをコピーする
function! delphinus#qfixhowm#markdown_to_mail() abort
  execute '%s/\t$//'
  call delphinus#qfixhowm#select_one_entry()
  echo 'yank to remote for mail'
endfunction
