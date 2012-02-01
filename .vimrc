scriptencoding 'utf-8'
let g:is_remora_cx = hostname() == 'remora.cx'
let g:is_remora = hostname() =~ '^remora'
let g:is_backup = hostname() == 'backup.remora.cx'
let g:is_office = len($H) > 0 && has('unix')
let g:is_office_win = len($USERDOMAIN) && has('win32')
let g:is_office_cygwin = len($USERDOMAIN) && has('win32unix')
let g:is_xerxes = hostname() == 'xerxes'
let g:is_remora_air2_win = hostname() == 'remora-air2-win'
let g:is_unix = is_remora || is_backup || is_office || is_office_cygwin
let g:is_win = is_office_win || is_xerxes || is_remora_air2_win

" シェルの位置を元に戻す
if is_office
	set shell=/bin/sh
elseif is_office_win
	set shell=$SYSTEMROOT\system32\cmd.exe
endif

set nocompatible
filetype off

if is_remora || is_office_cygwin || is_backup
	set rtp+=~/.vim/vundle
	let g:bundle_dir = expand('~/.vim/bundle')
elseif is_office 
	set rtp-=$HOME/.vim
	set rtp+=$H/.vim/vundle/
	let g:bundle_dir = expand('$H/.vim/bundle')
elseif is_win
	set rtp+=$HOME/.vim/vundle
	let g:bundle_dir = expand('$H/.vim/bundle')
endif

if ! isdirectory(g:bundle_dir)
	call mkdir(g:bundle_dir)
endif

call vundle#rc(g:bundle_dir)

Bundle 'bcat/abbott.vim'
Bundle 'fuenor/qfixhowm'
Bundle 'fuenor/vim-make-syntax'
Bundle 'fuenor/JpFormat.vim'
Bundle 'h1mesuke/unite-outline'
Bundle 'jelera/vim-javascript-syntax'
Bundle 'gregsexton/VimCalc'
Bundle 'houtsnip/vim-emacscommandline'
Bundle 'godlygeek/csapprox'
Bundle 'jnurmine/Zenburn'
"Bundle 'Lokaltog/vim-powerline'
Bundle 'delphinus35/vim-powerline'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'pix/vim-align'
Bundle 'rainux/vim-desert-warm-256'
Bundle 'Shougo/unite.vim'
Bundle 'Shougo/vimfiler'
Bundle 'Shougo/vimproc'
Bundle 'Shougo/vimshell'
Bundle 'Shougo/neocomplcache'
Bundle 'thinca/vim-quickrun'
Bundle 'thinca/vim-ref'
Bundle 'thinca/vim-visualstar'
Bundle 'ujihisa/unite-colorscheme'
Bundle 'vim-jp/vimdoc-ja'
Bundle 'vim-scripts/calendar.vim--Matsumoto'
Bundle 'vim-scripts/Color-Sampler-Pack'
Bundle 'vim-scripts/compilerjsl.vim'
Bundle 'vim-scripts/DrawIt'
Bundle 'vim-scripts/Gundo'
Bundle 'vim-scripts/Perl-MooseX.Declare-Syntax'
Bundle 'vim-scripts/vcscommand.vim'

"Bundle 'surround.vim'
"Bundle 'neon-PK'

filetype plugin indent on

if is_remora || is_office_win || is_office_cygwin
	set rtp+=~/.vim/
elseif is_office
	set rtp^=$H/.vim/
endif

syntax on

" QFixHowm 設定
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
let cp_cmd='cp'
if is_office
	let g:qfixmemo_plugin_dir=expand('$H/.vim/bundle/qfixhowm')
elseif is_office_win
	let g:qfixmemo_plugin_dir=expand('$HOME/.vim/bundle/qfixhowm')
	let cp_cmd='copy'
else
	let g:qfixmemo_plugin_dir=expand('$HOME/.vim/bundle/qfixhowm')
endif
if !filereadable(g:qfixmemo_plugin_dir.'/plugin/qfixmemo-calendar.vim')
	let ret=system(cp_cmd.' '.g:qfixmemo_plugin_dir.'/misc/qfixmemo-calendar.vim '.g:qfixmemo_plugin_dir.'/plugin/')
endif

" calendar.vim--Matsumoto
let g:calendar_action='QFixMemoCalendarDiary'
let g:calendar_sign='QFixMemoCalendarSign'
let g:calendar_weeknm=1
let g:calendar_mruler='正月,如月,弥生,卯月,皐月,水無月,文月,葉月,長月,神無月,霜月,師走'
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

" カーソル形状の変更
" http://yakinikunotare.boo.jp/orebase2/vim/change_cursor_shape_in_terminal_with_mode_change
if is_unix
	let &t_SI = "\<Esc>]50;CursorShape=1\x7"
	let &t_EI = "\<Esc>]50;CursorShape=0\x7"
	"inoremap <Esc> <Esc>gg`]
endif

let mapleader='`'

nnoremap <Leader>f :VimFiler<CR>
nnoremap <F12> :VimFiler<CR>
"nnoremap <Leader>t :TlistToggle<CR>
"nnoremap <Leader>T :TlistUpdate<CR>
"nnoremap <C-X><C-N> gt
"nnoremap <C-X><C-P> gT
nnoremap <C-X><C-F> :tabm +1<CR>
nnoremap <C-X><C-B> :tabm -1<CR>
nnoremap <F1> :mak!<CR>
nnoremap <F2> :QFix<CR>
nnoremap k gk
nnoremap j gj
nnoremap <C-D> 3<C-D>
nnoremap <C-U> 3<C-U>
nnoremap <C-Z> <C-^>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <S-CR> :simalt ~x<CR>
nnoremap <C-CR> :simalt ~r<CR>
nnoremap <S-C-CR> :simalt ~n<CR>
"cnoremap <C-F> <Right>
"cnoremap <C-B> <Left>
"cnoremap <C-A> <Home>
"cnoremap <C-E> <End>
"cnoremap <ESC>f <C-Right>
"cnoremap <ESC>b <C-Left>
inoremap # X#
" Gundo
nnoremap <F5> :GundoToggle<CR>
" Mac OSXでのvim環境整理。.vimrcやらオヌヌメPlug inやらまとめ。
" http://d.hatena.ne.jp/yuroyoro/20101104/1288879591
"Escの2回押しでハイライト消去
nmap <ESC><ESC> ;nohlsearch<CR><ESC>
" ;でコマンド入力( ;と:を入れ替)
noremap ; :
noremap : ;
" * 設定
nnoremap * *N
nnoremap # #N
map * <Plug>(visualstar-*)N
map # <Plug>(visualstar-#)N
" 4-6
"nnoremap <silent> cy ce<C-R>0<ESC>:let@/=@1<CR>:noh<CR>
"vnoremap <silent> cy c<C-R>0<ESC>:let@/=@1<CR>:noh<CR>
"nnoremap <silent> ciy ciw<C-R>0<ESC>:let@/=@1<CR>:noh<CR>
"set number
set encoding=utf-8
set termencoding=utf-8
set hls
if is_office
	set fileencoding=eucjp
else
	set fileencoding=utf-8
endif
set fileencodings=ucs-bom,utf-8,eucjp,cp932,ucs-2le,latin1,iso-2022-jp
set noexpandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set dir=/tmp
if is_office
	set backupdir=$H/tmp
	set undodir=$H/tmp
else
	set backupdir=/tmp
	set undodir=/tmp
endif
set undofile
set ruler
set scrolloff=3
set ignorecase smartcase
set autoindent
set smartindent
set textwidth=0
"set formatoptions=croqwanmB
set formatlistpat=^\\s*\\%(\\d\\+\\\|[-a-z]\\)\\%(\\\ -\\\|[]:.)}\\t]\\)\\?\\s\\+
set smarttab
set showcmd
set showmode
set fileformats=unix,dos
set fileformat=unix
set sessionoptions+=resize
set incsearch
set showmatch
set title
set mouse=
set display=lastline,uhex
set cul
set backspace=indent,eol,start
set clipboard=autoselectml
" grepコマンドとしてack（App::Ackのフロントエンド）を使用する
set grepprg=ack
" diffコマンド設定
set diffopt=filler,vertical
" 構文強調表示桁数の制限を解除
set synmaxcol=0
" 空白の可視化
set list
set listchars=tab:»\ ,trail:¯,eol:↲,extends:»,precedes:«,nbsp:¯
" unite.vim + 日本語ヘルプでフリーズするときの対策
set notagbsearch
set background=dark
" 5-5 10進数で数字の上げ下げ
set nrformats=
" ウィンドウタイトルを更新しない
set notitle
" 全角文字は全角用フォントで表示
set ambiwidth=double
"colo calmar256-light
"colo xorium
"colo desertEx
"colo werks
"colo bandit
"colo baycomb
"hi NonText ctermfg=238
"hi SpecialKey ctermfg=238
"hi CursorLine term=none ctermbg=238
"colo abbott
"colo desert-warm-256
"colo neon-PK
"colo rhinestones
colo zenburn
filetype plugin on

"-----------------------------------------------------------------------------
" ステータスバー設定
"-----------------------------------------------------------------------------
set laststatus=2
hi User1 term=NONE cterm=NONE ctermfg=black ctermbg=blue
hi User2 term=NONE cterm=NONE ctermfg=black ctermbg=magenta
hi User3 term=NONE cterm=NONE ctermfg=black ctermbg=red
hi User4 term=NONE cterm=NONE ctermfg=black ctermbg=green
hi User5 term=NONE cterm=NONE ctermfg=black ctermbg=cyan
hi User6 term=NONE cterm=NONE ctermfg=black ctermbg=cyan
hi User7 term=NONE cterm=NONE ctermfg=black ctermbg=cyan
hi User8 term=NONE cterm=NONE ctermfg=black ctermbg=yellow

"set statusline=
"set statusline+=%*%1*%w
"set statusline+=%y
"set statusline+=%2*%{GetStatusEx()}
"set statusline+=%8*[\ %{GetCurrentDir()}\ ]
"set statusline+=%*\ %t\ %*
"set statusline+=%3*%m
"set statusline+=%4*%r
"set statusline+=%*%=
"set statusline+=%5*R%4l\/%4P\ %6*C%3c%3V
"set statusline+=%7*[CODE\ %04B]
"set statusline+=%*

function! GetStatusEx()
  let str = ''
  let str = str . '' . &fileformat . ']'
  if has('multi_byte') && &fileencoding != ''
    let str = '[' . &fileencoding . ':' . str

  else
    let str = '[' . str
  endif
  return str
endfunction
function! GetCurrentDir()
  let str = ''
  let str = str . expand('%:p:h')
  let str = substitute(str, expand('$H'), '$H', '')
  let str = substitute(str, expand('$HOME'), '~', '')
  if len(str) > winwidth(1) / 3
    " バックスラッシュに囲まれた部分の最初の一文字にマッチするパターン
    let str = substitute(str, '\v%(/)@<=([^/]{2}).{-}%(/)@=', '\1', 'g')
  endif
  return str
endfunction

function! MyHL ()
    set cursorline
    hi User1 term=NONE cterm=NONE ctermfg=black ctermbg=blue    guifg=white guibg=darkblue      gui=bold
    hi User2 term=NONE cterm=NONE ctermfg=black ctermbg=magenta guifg=white guibg=darkmagenta   gui=bold
    hi User3 term=NONE cterm=NONE ctermfg=black ctermbg=red     guifg=white guibg=darkred       gui=bold
    hi User4 term=NONE cterm=NONE ctermfg=black ctermbg=green   guifg=white guibg=darkgreen     gui=bold
    hi User5 term=NONE cterm=NONE ctermfg=black ctermbg=cyan    guifg=white guibg=blueviolet    gui=bold
    hi User6 term=NONE cterm=NONE ctermfg=black ctermbg=cyan    guifg=white guibg=blueviolet    gui=bold
    hi User7 term=NONE cterm=NONE ctermfg=black ctermbg=cyan    guifg=white guibg=darkcyan      gui=bold
    hi User8 term=NONE cterm=NONE ctermfg=black ctermbg=cyan    guifg=white guibg=darkslategray gui=bold
    "hi Cursor guifg=White guibg=mediumorchid
    hi CursorIM guifg=black guibg=darkred
    "if &background == 'dark'
        "hi CursorLine guibg=gray10
    "else
        "hi CursorLine guibg=khaki
    "endif
    hi lCursor guifg=white guibg=Cyan
    hi iCursor guifg=black guibg=blue
    hi rCursor guifg=white guibg=red
    hi oCursor guifg=white guibg=DarkSlateGrey
    hi vCursor guifg=white guibg=orange
    hi sCursor guifg=white guibg=darkred
endfunction
"call MyHL()
"au ColorScheme * call MyHL()

"-----------------------------------------------------------------------------
" タブバー設定
"-----------------------------------------------------------------------------

set tabline=%!MyTabLine()
function! MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'

    " the label is made by MyTabLabel()
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999XClose'
  endif

  return s
endfunction

function! MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  " SVN のホームディレクトリを消す
  let altbuf = substitute(bufname(buflist[winnr - 1]), '^/home/game/svn/game/', '', '')
  " $H や $HOME を消す
  if g:is_office || g:is_office_cygwin || g:is_remora
	let altbuf = substitute(altbuf, expand('$H/'), '', '')
	let altbuf = substitute(altbuf, expand('$HOME/'), '', '')
  elseif g:is_office_win
	let altbuf = substitute(altbuf, substitute(substitute(expand('$HOME\'), '^c:', '', ''), '\\', '\\\\', 'g'), '', '')
endif
  " ディレクトリ名を縮める
  "let altbuf = substitute(altbuf, '\v%(\/)@<=(.).{-}%(\/)@=', '\1', 'g')
  " 拡張子を取る
  "let altbuf = substitute(altbuf, '\v%([^/])@<=\.[^.]+$', '', '')
  " [ref] 対応
  let altbuf = substitute(altbuf, '\[ref-.*:\(.*\)\]', '[\1]', 'g')
  let altbuf = '|' . altbuf . '|'
  return altbuf
endfunction

"-----------------------------------------------------------------------------
" ヘルプ
function! s:VertHelp(word)
  exec 'vertical help ' . a:word
  exec 'vertical resize 80'
  exec 'setl wfw'
endfunction
command! -nargs=? H call s:VertHelp(<f-args>)
autocmd FileType help nnoremap <buffer>q :q<CR>

"-----------------------------------------------------------------------------
" ファイルのあるディレクトリに移動
command! CD :cd %:h

"-----------------------------------------------------------------------------
" 各種プラグイン設定
"-----------------------------------------------------------------------------
" quickrun
" 他のと干渉するのでマッピングはしない
let g:quickrun_no_default_key_mappings=1
" 必要なモジュールをロード
let g:quickrun_config = {
\   'perl' : {
\       'exec' : 'perl -M5.12.0 -MYAML -Mutf8 %s',
\       'command' : 'perl',
\       'comopt' : '-M5.12.0 -MYAML -Mutf8',
\       'eval' : 1,
\       'eval_template': 'no strict;binmode STDOUT,":encoding(utf8)";$e=eval{%s};say$e?Dump($e):$@',
\   }
\}
" ビジュアルモードで選択した部分を実行
command! -range R :QuickRun perl -mode v
"command! R :QuickRun perl -mode v

"-----------------------------------------------------------------------------
" Perl 関連
let perl_include_pod=1
if is_office
	au BufNewFile,BufRead *.conf se ft=perl
	au BufNewFile,BufRead _inc_html.txt se ft=html
endif

" zencoding-vim
let g:user_zen_settings = {
\   'indentation' : '    ',
\   'lang' : 'ja',
\   'perl' : {
\       'aliases' : {
\           'req' : 'require '
\       },
\       'snippets' : {
\           'use' : "#!/usr/bin/perl;\nuse utf8;\nuse strict\nuse warnings\nuse errors -with_using;\nuse feature qw! say !;\n\n",
\           'moose' : "#!/usr/bin/perl;\nuse utf8;\nuse Moose;\nuse errors -with_using;\nuse feature qw! say !;\n\n|\n\n__PACKAGE__->meta->make_immutable;",
\       }
\   }
\}
let g:user_zen_expandabbr_key = '<c-q>'
let g:user_zen_complete_tag = 1

"-----------------------------------------------------------------------------
" vim-ref
let g:ref_open=':vsp'
let g:ref_alc_start_linenumber=42
noremap <Leader>ra :Unite ref/alc<CR>
noremap <Leader>rc :Unite ref/clojure<CR>
noremap <Leader>re :Unite ref/erlang<CR>
noremap <Leader>rm :Unite ref/man<CR>
noremap <Leader>rp :Unite ref/perldoc<CR>
noremap <Leader>rh :Unite ref/phpmanual<CR>
noremap <Leader>ry :Unite ref/pydoc<CR>
noremap <Leader>rr :Unite ref/refe<CR>
noremap <Leader>rv :vert res 80<CR>
autocmd FileType ref call s:initialize_ref_viewer()
function! s:initialize_ref_viewer()
	noremap <buffer><C-T> :Unite tab<CR>
endfunction

"-----------------------------------------------------------------------------
" netrwの設定
let g:netrw_altv=1
let g:netrw_liststyle=1
let g:netrw_winsize=90

"-----------------------------------------------------------------------------
"" Unite.vimの設定
"" 開始と同時に挿入モード
let g:unite_enable_start_insert=1
"" 縦に分割して表示
"let g:unite_enable_split_vertically=0
"" 横幅は60
"let g:unite_winwidth=80
"" 時刻表示形式 → (月) 01/02 午後 03:45
let g:unite_source_file_mru_time_format='(%a) %m/%d %p %I:%M '
"" zip, asp ファイルが多すぎて遅くなるので除外
"let g:unite_source_file_ignore_pattern='\%(^\|/\)\.$\|\~$\|\.\%(o|exe|dll|bak|sw[po]\)$\|\.asp$\|\.zip$'
"" // が頭に来るパスを除外
"let g:unite_source_file_mru_ignore_pattern='\~$\|\.\%(o|exe|dll|bak|sw[po]\)$\|\%(^\|/\)\.\%(hg\|git\|bzr\|svn\)\%($\|/\)\|^\%(//\|\\\\\|/mnt/\|/media/\|/Volumes/\)'
" データファイル
if is_office
	let g:unite_data_directory = expand('$H/.unite')
endif
noremap <C-P> :Unite buffer_tab file_mru<CR>
noremap <C-N> :UniteWithBufferDir -buffer-name=files file<CR>
noremap <C-Z> :Unite outline<CR>
noremap <C-T> :Unite tab<CR>
noremap <Leader>uc :Unite colorscheme -auto-preview<CR>
noremap <Leader>ul :Unite locate<CR>
noremap <Leader>uv :Unite buffer -input=vimshell<CR>
noremap <Leader>vu :Unite buffer -input=vimshell<CR>
autocmd FileType unite call s:unite_my_settings()
autocmd FileType unite nnoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
autocmd FileType unite inoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
autocmd FileType unite nnoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
autocmd FileType unite inoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
autocmd FileType unite nnoremap <silent> <buffer> <expr> <C-T> unite#do_action('tabopen')
autocmd FileType unite inoremap <silent> <buffer> <expr> <C-T> unite#do_action('tabopen')
autocmd FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
autocmd FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>
call unite#set_substitute_pattern('files', '\$\w\+', '\=eval(submatch(0))', 200)
call unite#set_substitute_pattern('files', '^@@', '\=fnamemodify(expand("#"), ":p:h")."/"', 2)
call unite#set_substitute_pattern('files', '^@', '\=getcwd()."/*"', 1)
call unite#set_substitute_pattern('files', '^;r', '\=$VIMRUNTIME."/"')
call unite#set_substitute_pattern('files', '^\~', escape($HOME, '\'), -2)
call unite#set_substitute_pattern('files', '\\\@<! ', '\\ ', -20)
call unite#set_substitute_pattern('files', '\\ \@!', '/', -30)
if is_office
	call unite#set_substitute_pattern('files', '^;h', '\=$H."/"')
	call unite#set_substitute_pattern('files', '^;s', '/home/game/svn/game/')
endif
if has('win32') || has('win64')
  call unite#set_substitute_pattern('files', '^;p', 'C:/Program Files/')
endif
call unite#set_substitute_pattern('files', '^;v', '~/.vim/')
function! s:unite_my_settings()
  " Overwrite settings.
endfunction


"-----------------------------------------------------------------------------
" Tlist 設定
"let Tlist_Enable_Fold_Column=0
"let Tlist_Process_File_Always=1

"-----------------------------------------------------------------------------
" SQLUtilities
"vmap <silent>sf        <Plug>SQLU_Formatter<CR>
"nmap <silent>scl       <Plug>SQLU_CreateColumnList<CR>
"nmap <silent>scd       <Plug>SQLU_GetColumnDef<CR>
"nmap <silent>scdt      <Plug>SQLU_GetColumnDataType<CR>
"nmap <silent>scp       <Plug>SQLU_CreateProcedure<CR> 

"-----------------------------------------------------------------------------
" ユーザー定義コマンド
"-----------------------------------------------------------------------------
" http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
" toggles the quickfix window.
let g:jah_Quickfix_Win_Height=10
command! -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
	if exists('g:qfix_win') && a:forced == 0
		cclose
	else
		execute 'copen ' . g:jah_Quickfix_Win_Height
	endif
endfunction

" used to track the quickfix window
augroup QFixToggle
	autocmd!
	autocmd BufWinEnter quickfix let g:qfix_win = bufnr('$')
	autocmd BufWinLeave * if exists('g:qfix_win') && expand('<abuf>') == g:qfix_win | unlet! g:qfix_win | endif
augroup END

"-----------------------------------------------------------------------------
" Apache 再起動
if is_office
	function! RestartApache()
		call system('sudo /usr/local/apache/bin/apachectl graceful')
		echo 'apache restarted'
	endfunction
	nnoremap <silent> <unique> <Leader>h :call RestartApache()<CR>
endif

"-----------------------------------------------------------------------------
" Teamplte::Toolkit 設定
au BufNewFile,BufRead *.tt2 setf tt2html
au BufNewFile,BufRead *.tt setf tt2html

"-----------------------------------------------------------------------------
" pentadactylrc 設定
au BufNewFile,BufRead .pentadactylrc setf pentadactyl

"-----------------------------------------------------------------------------
" yank to remote clipboard
if is_unix
	let s:tmpdir = &backupdir
	let s:home = is_office ? expand('$H') : expand('$HOME')
	let g:y2r_config = {
	\	'tmp_file': s:tmpdir . '/exchange-file',
	\	'key_file' : s:home . '/.exchange.key',
	\	'host' : 'localhost',
	\	'port' : 52224,
	\}

	function! Yank2Remote()
		call writefile(split(@", '\n'), g:y2r_config.tmp_file, 'b')
		let s:params = ['cat %s %s | nc -w1 %s %s']
		for s:item in ['key_file', 'tmp_file', 'host', 'port']
		let s:params += [shellescape(g:y2r_config[s:item])]
		endfor
		let s:ret = system(call(function('printf'), s:params))
		echo 'paste to remote'
	endfunction
	nnoremap <silent> <unique> <Leader>y :call Yank2Remote()<CR>
endif

"-----------------------------------------------------------------------------
" vimfiler

" :edit で vimfiler を起動
let g:vimfiler_as_default_explorer = 1

"-----------------------------------------------------------------------------
" compiler/jsl.vim
if is_office
	let g:jsl_config=expand('$H/bin/jsl.conf')
endif

"-----------------------------------------------------------------------------
" neocomplcache
let g:neocomplcache_enable_at_startup=1
"imap <c-o> <Plug>(neocomplcache_snippets_expand)
"smap <c-o> <Plug>(neocomplcache_snippets_expand)

"-----------------------------------------------------------------------------
" VimShell
" プロンプトにカレントディレクトリを表示
let g:vimshell_user_prompt = 'getcwd()'
" 初期化ファイルの場所を指定
if is_office
	let g:vimshell_vimshrc_path=expand('$H/.vimshrc')
else
	let g:vimshell_vimshrc_path=expand('$HOME/.vimshrc')
endif
nnoremap <Leader>vv :VimShell<CR>
nnoremap <Leader>vc :VimShellCreate<CR>
nnoremap <Leader>vt :VimShellTab<CR>
autocmd FileType vimshell noremap <buffer><C-P> :Unite buffer_tab file_mru<CR>
autocmd FileType vimshell noremap <buffer><C-N> :UniteWithBufferDir -buffer-name=files file<CR>
autocmd FileType vimshell noremap <buffer><C-X><C-P> <Plug>(vimshell_int_previous_prompt)
autocmd FileType vimshell noremap <buffer><C-X><C-N> <Plug>(vimshell_int_next_prompt)
autocmd FileType vimshell nnoremap <buffer><C-K> <C-W><C-K>
autocmd FileType vimshell nnoremap <buffer><C-L> <C-W><C-L>
autocmd FileType vimshell nnoremap <buffer><C-X><C-K> <Plug>(vimshell_delete_previous_output)
autocmd FileType vimshell nnoremap <buffer><C-X><C-L> <Plug>(vimshell_clear)
autocmd FileType vimshell nnoremap <buffer><C-T> :Unite tab<CR>
autocmd FileType vimshell inoremap <buffer><C-T> <ESC>:Unite tab<CR>

"-----------------------------------------------------------------------------
" DrawIt
" 日本語文字用
let g:Align_xstrlen=3
let g:DrChipTopLvlMenu=''
" 設定リセットコマンド
command! -nargs=0 AlignReset call Align#AlignCtrl("default")

"-----------------------------------------------------------------------------
" diff
" diff 開始
command! -nargs=0 DT :diffthis
command! -nargs=0 DO :diffoff!

"-----------------------------------------------------------------------------
" str2time()
" Perl の HTTP::Date::str2time() を使って epoch 時を得る
function! Str2time(str)
	let s:curline=getline('.')
	let s:row=line('.')
	let s:cur=col('.')
	let s:left=strpart(s:curline, 0, s:cur - 1)
	let s:right=strpart(s:curline, s:cur - 1)

	if (0)
		perl <<EOP
		use HTTP::Date;
		$epoch = str2time(VIM::Eval('a:str'), '+0900');
		$curbuf->Set(VIM::Eval('s:row'), VIM::Eval('s:left') . $epoch . VIM::Eval('s:right'));
		$curwin->Cursor(VIM::Eval('s:row'), VIM::Eval('s:cur') + length $epoch);
EOP

	else
		if (match(a:str, '^\d\+$') == 0)
			let s:time=system('perl -MHTTP::Date -e"print HTTP::Date::time2iso('.a:str.')"')
		else
			let s:time=system('perl -MHTTP::Date -e"print str2time(q{'.a:str.'})"')
		endif
		call setline(line('.'), s:left.s:time.s:right)
		call cursor(line('.'), col('.') + len(s:time))
	endif
endfunction
command! -nargs=1 ST :call Str2time('<args>')

"-----------------------------------------------------------------------------
" SVN 設定
command! -nargs=0 SD :VCSDiff HEAD

"-----------------------------------------------------------------------------
" vim-powerline
let g:Powerline_symbols = 'fancy'

"-----------------------------------------------------------------------------
" JpFormat.vim
" 現在行を整形
nnoremap <silent> gl :JpFormat<CR>
" 現在行が整形対象外でも強制的に整形
nnoremap <silent> gL :JpFormat!<CR>
" 自動整形のON/OFF切替
" 30gc の様にカウント指定すると、折り返し文字数を指定されたカウントに変更します。
nnoremap <silent> gc :JpFormatToggle<CR>

" カーソル位置の分割行をまとめてヤンク
nnoremap <silent> gY :JpYank<CR>
" カーソル位置の分割行をまとめて連結
nnoremap <silent> gJ :JpJoin<CR>

" 整形に gqを使うかどうかをトグルする
nnoremap <silent> gC :JpFormatGqToggle<CR>
" 外部ビューアを起動する
nnoremap <silent> <F8> :JpExtViewer<CR>
" txtファイルで「連結マーカー+改行」が有ったら自動整形を有効にする
au BufRead *.txt  silent! call JpSetAutoFormat()

" 日本語の行の連結時には空白を入力しない。
set formatoptions+=mM
" iText Expressで開く
let ExtViewer_txt = '!open -a "iText Express" "%f"'
" 外部ビューアに渡すファイル名
let EV_Tempname_txt = '/tmp/.evtemp'


"-----------------------------------------------------------------------------
" Ricty 使うようになったらいらなくなった
" 全角スペース・行末のスペース・タブの可視化
if has('syntax')
    "syntax on

    " PODバグ対策
    "syn sync fromstart

    "function! ActivateInvisibleIndicator()
        "syntax match InvisibleJISX0208Space "　" display containedin=ALL
        "highlight InvisibleJISX0208Space term=underline ctermbg=Blue guibg=darkgray gui=underline
        "syntax match InvisibleTrailedSpace "[ \t]\+$" display containedin=ALL
        "highlight InvisibleTrailedSpace term=underline ctermbg=Red guibg=NONE gui=undercurl guisp=darkorange
        "syntax match InvisibleTab "\t" display containedin=ALL
        "highlight InvisibleTab term=underline ctermbg=white gui=undercurl guisp=darkslategray
    "endf
    "augroup invisible
        "autocmd! invisible
        "autocmd BufNew,BufRead * call ActivateInvisibleIndicator()
    "augroup END
endif
