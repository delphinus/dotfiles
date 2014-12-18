"-----------------------------------------------------------------------------
" 時刻表示形式 → (月) 01/02 午後 03:45
let g:neomru#time_format='%m/%d %k:%M '
" プロンプト
let g:unite_prompt=' '
" 挿入モードで開く
let g:unite_enable_start_insert=1
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

noremap zd :Unite dwm<CR>
noremap zf :Unite qfixhowm/new qfixhowm<CR>
noremap zF :Unite qfixhowm/new qfixhowm:nocache<CR>
noremap zi :Unite tig<CR>
noremap zl :Unite outline<CR>
noremap zn :UniteWithBufferDir -buffer-name=files file file/new<CR>
noremap zp :Unite dwm buffer_tab file_mru:long<CR>
noremap zP :Unite output<CR>
noremap zr :Unite ruby/require<CR>
noremap zy :Unite yankround<CR>
noremap zw :Unite webcolorname<CR>
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
call unite#custom#substitute('files', '^;d', escape($HOME, '\') . '/git/dotfiles/')
if has('win32') || has('win64')
  call unite#custom#substitute('files', '^;p', 'C:/Program Files/')
  call unite#custom#substitute('files', '^;u', escape($USERPROFILE, '\') . '/')
endif

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
    imap <silent> <buffer> <F10> <Plug>(unite_select_next_line)
    imap <silent> <buffer> <F11> <Plug>(unite_select_next_line)
    imap <silent> <buffer> <F12> <Plug>(unite_select_next_line)
    " ノーマルモードで上下移動
    nmap <silent> <buffer> <C-K> <Plug>(unite_select_previous_line)
    nmap <silent> <buffer> <C-J> <Plug>(unite_select_next_line)
    " ノーマルモードでソース選択
    nmap <silent> <buffer> <F10> <Plug>(unite_rotate_next_source)
    nmap <silent> <buffer> <F11> <Plug>(unite_rotate_next_source)
    nmap <silent> <buffer> <F12> <Plug>(unite_rotate_next_source)
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

" grep検索
nnoremap zg :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
" カーソル位置の単語をgrep検索
nnoremap zu :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>
" grep検索結果の再呼出
nnoremap zG :<C-u>UniteResume search-buffer<CR>

" unite grep に ag(The Silver Searcher) を使う
let is_32bit = system('uname -m')
if has('macunix') && executable('pt')
    let g:unite_source_grep_command = '/usr/local/bin/pt'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor'
    let g:unite_source_grep_recursive_opt = ''
elseif has('win64') && executable('pt')
    let g:unite_source_grep_command = 'pt'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor'
    let g:unite_source_grep_recursive_opt = ''
elseif has('unix') && executable('pt_linux32') && system('uname -m') == "i686\n"
    let g:unite_source_grep_command = 'pt_linux32'
    let g:unite_source_grep_recursive_opt = ''
    let g:unite_source_grep_default_opts = '--nogroup --nocolor'
elseif has('unix') && executable('pt_linux')
    let g:unite_source_grep_command = 'pt_linux'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor'
    let g:unite_source_grep_recursive_opt = ''
elseif executable('ag')
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '-a --nogroup --nocolor --column'
    let g:unite_source_grep_recursive_opt = ''
endif

" unite-tag 設定
autocmd BufEnter *
\   if empty(&buftype)
\|      nnoremap <buffer> <C-]> :<C-u>UniteWithCursorWord -immediately tag/include<CR>
\|  endif
