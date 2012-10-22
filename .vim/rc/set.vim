" エンコーディング {{{
set encoding=utf-8         " 内部エンコーディング
set termencoding=utf-8     " ターミナルのエンコーディング
if is_office
    set fileencoding=eucjp " 新規ファイルのエンコーディング
else
    set fileencoding=utf-8
endif
                           " ファイルエンコーディング
set fileencodings=ucs-bom,utf-8,eucjp,cp932,ucs-2le,latin1,iso-2022-jp
" }}}

" タブ {{{
if is_office_alt
    set expandtab
elseif is_office
    set noexpandtab " タブをスペースに展開する
else
    set expandtab
endif
set tabstop=4       " 画面上でタブ文字が占める幅
set softtabstop=4   " タブキーやバックスペースキーでカーソルが動く幅
set shiftwidth=4    " 自動インデントや <<, >> でずれる幅
set smarttab        " スマートなタブ切り替え
" }}}

" ディレクトリ {{{
set undofile             " アンドゥファイルを保存する
if is_office
    set dir=$H/tmp       " スワップファイルの作成場所
    set backupdir=$H/tmp " バックアップファイルの作成場所
    set undodir=$H/tmp   " アンドゥファイルの作成場所
else
    set dir=/tmp
    set backupdir=/tmp
    set undodir=/tmp
endif
" }}}

" 検索 {{{
set ignorecase " 検索時に大文字・小文字を区別しない
set smartcase  " 検索パターンの大文字・小文字自動認識
set hlsearch   " 検索パターンを強調表示
set incsearch  " インクリメンタルサーチ
" }}}

" インデントと整形 {{{
set autoindent       " 自動インデント
set smartindent      " スマートなインデント
set textwidth=0      " 自動改行はオフ
set formatoptions+=n " テキスト整形オプション
                     " 括弧付きの連番を認識する
set formatlistpat=^\\s*\\%(\\d\\+\\\|[-a-z]\\)\\%(\\\ -\\\|[]:.)}\\t]\\)\\?\\s\\+
" }}}

" 画面表示 {{{
set t_Co=256             " 256 色表示ターミナル対応
set nocursorline         " カーソル行を強調表示しない
set showcmd              " コマンド、及び選択範囲の表示
set noshowmode           " 【挿入】【ビジュアル】といった文字列を画面最下段に表示しない
set showmatch            " 対応する括弧を自動的に装飾して表示
set display=lastline     " 画面最下行もできるだけ表示する
set laststatus=2         " ステータスラインは常に表示
set relativenumber       " 相対行番号を表示する
set numberwidth=3        " 行番号の幅は 3 桁
set colorcolumn=80       " 80 桁目をハイライト
set list                 " 空白の可視化

" 挿入モードの時のみ、カーソル行をハイライトする
autocmd InsertEnter,InsertLeave * set cul!

if is_remora
    set listchars=tab:»\ ,trail:¯,eol:↲,extends:»,precedes:«,nbsp:¯
else
    "set listchars=tab:▓█,trail:▓,eol:↲,extends:»,precedes:«,nbsp:¯
    set listchars=tab:░\ ,trail:░,eol:↲,extends:»,precedes:«,nbsp:¯
endif
set cmdheight=2          " 画面最下段のコマンド表示行数

if g:is_remora
    set ambiwidth=double " アスキー文字以外は全角文字として扱う
else
    set ambiwidth=single " できるだけ半角文字幅で扱う
endif
" }}}

" マウス {{{
set mouse=a " マウスを全ての場面で使う
set ttymouse=xterm2 " マウスホイールを有効化
set clipboard=autoselectml " モードレスセレクション時に OS 標準のクリップボードを使う
" }}}

set scrolloff=3                   " 上下の画面の端にカーソルを寄せない。
set sidescrolloff=5               " 左右の画面の端にカーソルを寄せない。

set fileformat=unix               " 改行コード指定
set fileformats=unix,dos          " 改行コード自動認識

set backspace=indent,eol,start    " バックスペースを行を超えて有効にする

set grepprg=ack                   " grep コマンドとして ack を使用する

set diffopt=filler,vertical       " diffコマンド設定

set synmaxcol=0                   " 構文強調表示桁数の制限を解除

set notagbsearch                  " unite.vim + 日本語ヘルプでフリーズするときの対策

set nrformats=                    " 5-5 10進数で数字の上げ下げ

set timeout                       " キーのタイムアウト時間設定
set timeoutlen=1000
set ttimeoutlen=75

set virtualedit=block             " ビジュアルブロックモードのみ、カーソルを自由移動させる

set showbreak=\ +\                " 折り返したときに行頭に文字を表示
set cpoptions+=n

set updatetime=1000               " スワップファイルが書き込まれるまでの時間。

set background=dark               " 暗い背景色

" 一部の端末は明るい背景
if is_office_alt
    set background=light              " 明るい背景色
endif

let g:solarized_termtrans=1         " 背景を透過する
let g:solarized_visibility='normal' " 不可視文字を高コントラストで表示する
let g:badwolf_html_link_underline = 1
let g:badwolf_css_props_highlight = 1

colo solarized

"colo festoon
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
"colo gummybears
"colo void256
"colo badwolf
"colo zenburn

" vim:et:fdm=marker:
