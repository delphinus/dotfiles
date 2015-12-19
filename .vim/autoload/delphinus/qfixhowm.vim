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
      let l:ext = gista#utils#guess_extension(l:file_type)
      let l:current_ext = '.' . expand('%:e')
      if ! empty(l:ext) && l:ext !=? l:current_ext
        let l:new_filename = expand('%:t:r') . l:ext
      endif
    endif
  else
    let l:new_filename = expand('%:t:r') . '.markdown'
  endif

  execute printf('%d,%dGist --description "%s"', l:start_line, l:end_line, l:title)
  let l:url = @"
  let @* = l:url

  if ! empty(l:new_filename)
    let l:gistid = matchstr(l:url, '[0-9a-f]\+$')
    call gista#interface#rename_action(l:gistid, l:filename, l:new_filename)
  endif

  call gista#utils#browse(l:url)
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
