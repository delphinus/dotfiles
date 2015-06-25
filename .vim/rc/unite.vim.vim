"-----------------------------------------------------------------------------
" 時刻表示形式 → (月) 01/02 午後 03:45
let g:neomru#time_format='%m/%d %k:%M '
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

autocmd FileType unite call s:unite_my_settings()

call unite#custom#substitute('files', '\$\w\+', '\=eval(submatch(0))', 200)
call unite#custom#substitute('files', '^@@', '\=fnamemodify(expand("#"), ":p:h")."/"', 2)
call unite#custom#substitute('files', '^@', '\=getcwd()."/*"', 1)
call unite#custom#substitute('files', '^;r', '\=$VIMRUNTIME."/"')
call unite#custom#substitute('files', '^\~', escape($HOME, '\'), -2)
call unite#custom#substitute('files', '\\\@<! ', '\\ ', -20)
call unite#custom#substitute('files', '\\ \@!', '/', -30)
call unite#custom#substitute('files', '^;v', '~/.vim/')
call unite#custom#substitute('files', '^;g', escape($HOME, '\') . '/git/')

call unite#custom#profile('default', 'context', {
      \ 'start_insert': 1
      \ })

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

" custom_filters {{{
let s:custom_filters = []

if neobundle#is_sourced('vim-webdevicons')
  let s:webdevicons = {'name': 'webdevicons'}
  function! s:webdevicons.filter(candidates, context)
    for candidate in a:candidates
      if has_key(candidate, 'icon')
        continue
      endif
      let path = has_key(candidate, 'action__path') ? candidate.action__path : candidate.word
      let isdir = isdirectory(path)
      let candidate.icon = WebDevIconsGetFileTypeSymbol(path, isdir)
      if has_key(candidate, 'abbr')
        let abbr = candidate.abbr
      elseif isdir && path !~ '/$'
        let abbr = path . '/'
      else
        let abbr = path
      endif
      let candidate.abbr = candidate.icon . '  ' . abbr
    endfor
    return a:candidates
  endfunction

  call unite#define_filter(s:webdevicons)
  let s:custom_filters = s:custom_filters + ['webdevicons']
endif

let s:dir_filter = {'name': 'dir_filter'}
function! s:dir_filter.filter(candidates, context)
  for candidate in a:candidates
    let abbr = has_key(candidate, 'abbr') ? candidate.abbr : candidate.word
    let abbr = substitute(abbr, expand($HOME), '~', '')
    let candidate.abbr = abbr
  endfor
  return a:candidates
endfunction
call unite#define_filter(s:dir_filter)
let s:custom_filters = s:custom_filters + ['dir_filter']

function! MyUniq(list)
  let V = vital#of('vital')
  let O = V.import('Data.OrderedSet')
  let unique_set = O.new()
  for Item in a:list
    call unique_set.push(Item)
    unlet Item
  endfor
  return unique_set.to_list()
endfunction

let file_mru = unite#get_sources('file_mru')
if has_key(file_mru, 'converters') && count(file_mru.converters, 'webdevicons') == 0
  call unite#custom#source('file_mru', 'converters', MyUniq(file_mru.converters + s:custom_filters))
else
  call unite#custom#source('file_mru', 'converters', MyUniq(unite#sources#neomru#define()[0].converters + s:custom_filters))
endif

call unite#custom#source('file', 'converters', s:custom_filters)
call unite#custom#source('buffer_tab', 'converters', s:custom_filters)
call unite#custom#source('dwm', 'converters', s:custom_filters)
"}}}

" gista setting {{{
let s:gista_action = {'is_selectable': 0}

function! s:gista_action.func(candidate)
  let gist = a:candidate.source__gist
  call gista#interface#yank_url_action(gist.id)
  let @* = @"
endfunction

call unite#custom#action('gista', 'yank_url_to_system_clipboard', s:gista_action)
unlet s:gista_action
"}}}

" vim:se fdm=marker:
