scriptencoding utf-8
"-----------------------------------------------------------------------------
" 時刻表示形式 → (月) 01/02 午後 03:45
let g:neomru#time_format='%m/%d %k:%M '
" ファイル名形式
let g:neomru#filename_format = ':~:.'
" プロンプト
let g:unite_prompt=' '
" ステータスラインを書き換えない
let g:unite_force_overwrite_statusline=0
" ロングリストにたくさんファイルを保存
let g:neomru#file_mru_limit=100000
" 非同期検索の候補アイテム上限値
let g:unite_source_file_rec_max_cache_files=100000
" 画面を縦に分割して開かない
let g:unite_enable_split_vertically=0

" unite-qfixhowm 対応
" 更新日時でソート
call unite#custom_source('qfixhowm', 'sorters', ['sorter_qfixhowm_updatetime', 'sorter_reverse'])
" デフォルトアクション
let g:unite_qfixhowm_new_memo_cmd='dwm_new'

augroup UniteMySettings
  autocmd!
  autocmd FileType unite call s:unite_my_settings()
augroup END

call unite#custom#profile('default', 'context', {'start_insert': 1})

function! s:unite_my_settings()
    " タブで開く
    nnoremap <silent> <buffer> <expr> <C-T> unite#do_action('tabopen')
    inoremap <silent> <buffer> <expr> <C-T> unite#do_action('tabopen')
    " vimfiler で開く
    nnoremap <silent> <buffer> <expr> <C-O> unite#do_action('vimfiler')
    inoremap <silent> <buffer> <expr> <C-O> unite#do_action('vimfiler')
    " dwm.vim で開く
    nnoremap <silent> <buffer> <expr> <C-N> unite#do_action('dwm_new')
    inoremap <silent> <buffer> <expr> <C-N> unite#do_action('dwm_new')
    " rec/async で開く
    nnoremap <silent> <buffer> <expr> <C-A> unite#do_action('rec/async')
    inoremap <silent> <buffer> <expr> <C-A> unite#do_action('rec/async')
    " grep で開く
    nnoremap <silent> <buffer> <expr> <C-G> unite#do_action('grep')
    inoremap <silent> <buffer> <expr> <C-G> unite#do_action('grep')
    " 終了して一つ前に戻る
    nmap <silent> <buffer> <ESC><ESC> <Plug>(unite_exit)
    imap <silent> <buffer> <ESC><ESC> <Plug>(unite_exit)
    " Unite ウィンドウを閉じる
    imap <silent> <buffer> <C-C> <Esc><C-C>
    " インサートモードで上下移動
    imap <silent> <buffer> <C-K> <Plug>(unite_select_previous_line)
    imap <silent> <buffer> <C-J> <Plug>(unite_select_next_line)
    " ノーマルモードで上下移動
    nmap <silent> <buffer> <C-K> <Plug>(unite_select_previous_line)
    nmap <silent> <buffer> <C-J> <Plug>(unite_select_next_line)
    " 一つ上のパスへ
    imap <buffer> <C-U> <Plug>(unite_delete_backward_path)
    " 入力した文字を消す
    imap <buffer> <C-W> <Plug>(unite_delete_backward_word)
endfunction

" agとUnite.vimで快適高速grep環境を手に入れる - Thinking-megane
" http://blog.monochromegane.com/blog/2013/09/18/ag-and-unite/
" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1

" unite grep に ag(The Silver Searcher) を使う
if executable('pt')
    let g:unite_source_grep_command = 'pt'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor'
    let g:unite_source_grep_recursive_opt = ''
    let g:unite_source_file_async_command = 'pt --nocolor --nogroup -g .'
elseif executable('ag')
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '-a --nogroup --nocolor --column'
    let g:unite_source_grep_recursive_opt = ''
    let g:unite_source_file_async_command = 'ag --follow --nocolor --nogroup --hidden -g ""'
endif

call neobundle#source('neomru.vim')

call unite#custom#default_action('source/bundler/directory', 'file')

" devicons converter {{{
let s:devicons = {'name': 'devicons'}
function! s:devicons.filter(candidates, context)
  for candidate in filter(copy(a:candidates), "!has_key(v:val, 'icon')")
    let raw_path = get(candidate, 'action__path', candidate.word)
    let filename = fnamemodify(raw_path, ':p:t')
    let isdir = isdirectory(raw_path)
    let path = get(candidate, 'abbr', raw_path)
    if g:neomru#filename_format ==# ''
      let path = raw_path
    elseif filereadable(path) || isdir
      let path = fnamemodify(path, g:neomru#filename_format)
      if path ==# ''
        let path = '~'
      endif
    endif
    if isdir && path !~# '/$'
      let path .= '/'
    endif
    let candidate.icon = WebDevIconsGetFileTypeSymbol(filename, isdir)
    let candidate.abbr = candidate.icon . ' ' . path
  endfor
  return a:candidates
endfunction
call unite#define_filter(s:devicons)
unlet s:devicons
"}}}

" devicons_mru converter {{{
let s:devicons_mru = {'name': 'devicons_mru'}
function! s:devicons_mru.filter(candidates, context)
  if g:neomru#filename_format ==# '' && g:neomru#time_format ==# ''
    return a:candidates
  endif

  for candidate in filter(copy(a:candidates), "!has_key(v:val, 'abbr')")
    let raw_path = get(candidate, 'action__path', candidate.word)
    let filename = fnamemodify(raw_path, ':p:t')

    if g:neomru#time_format ==# ''
      let path = raw_path
    else
      let path = unite#util#substitute_path_separator(fnamemodify(raw_path, g:neomru#filename_format))
    endif
    if path ==# ''
      let path = raw_path
    endif

    let candidate.abbr = ''
    if g:neomru#time_format !=# ''
      let candidate.abbr .= strftime(g:neomru#time_format, getftime(raw_path))
    endif
    let candidate.abbr .= WebDevIconsGetFileTypeSymbol(filename, isdirectory(raw_path))
    if g:neomru#filename_format ==# ''
      let candidate.abbr .= ' ' . raw_path
    else
      let candidate.abbr .= ' ' . fnamemodify(raw_path, g:neomru#filename_format)
    endif
  endfor

  return a:candidates
endfunction
call unite#define_filter(s:devicons_mru)
unlet s:devicons_mru
"}}}

call unite#custom#profile('default',       'converters', ['devicons'])
call unite#custom#source('file',           'converters', ['devicons'])
call unite#custom#source('file_rec/git',   'converters', ['devicons'])
call unite#custom#source('file_rec/async', 'converters', ['devicons'])
call unite#custom#source('file_mru',       'converters', ['devicons_mru'])

" gista setting {{{
let s:gista_action = {
      \ 'is_selectable': 0,
      \ 'description': 'yank a gist url to system clipboard',
      \ }

if has('gui_running') && has('clipboard')
  function! s:gista_action.func(candidate)
    let gist = a:candidate.source__gist
    call gista#interface#yank_url_action(gist.id)
    let @* = @"
  endfunction
else
  function! s:gista_action.func(candidate)
    let gist = a:candidate.source__gist
    call gista#interface#yank_url_action(gist.id)
    let F = vital#of('vital').import('System.Filepath')
    if F.which('pbcopy') !=# ''
      call system(printf('echo "%s" | pbcopy', @"))
    elseif F.which('ui_copy') !=# ''
      call system(printf('echo "%s" | ui_copy', @"))
    endif
  endfunction
endif

call unite#custom#action('gista', 'yank_url_to_system_clipboard', s:gista_action)
unlet s:gista_action
"}}}

" vim:se fdm=marker:
