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
if is_office
	set ambiwidth=single
else
	set ambiwidth=double
endif
" マウスホイールを有効化
set ttymouse=xterm2
set mouse=a
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
"colo zenburn
"colo papayawhip
colo gummybears
filetype plugin on

