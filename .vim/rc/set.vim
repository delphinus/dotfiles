scriptencoding utf-8

" エンコーディング {{{
set fileencoding=utf-8 " 新規ファイルのエンコーディング
" 非GUI日本語コンソールを使っている場合の設定
if !has('gui_running') && &encoding !=# 'cp932' && &term ==# 'win32'
  set termencoding=cp932
else
  set termencoding=utf-8
endif
" ファイルエンコーディング
if ! (has('gui_macvim') && has('kaoriya'))
  set fileencodings=ucs-bom,utf-8,eucjp,cp932,ucs-2le,latin1,iso-2022-jp
endif
" }}}

" タブ {{{
set expandtab       " タブをスペースに展開する
set tabstop=2       " 画面上でタブ文字が占める幅
set softtabstop=2   " タブキーやバックスペースキーでカーソルが動く幅
set shiftwidth=2    " 自動インデントや <<, >> でずれる幅
set smarttab        " スマートなタブ切り替え
" }}}

" ディレクトリ {{{
set undofile                   " アンドゥファイルを保存する
set directory=/tmp
set backupdir=/tmp
set undodir=/tmp
set backupskip^=/private/tmp/* " Mac で crontab を使うための設定

if &shell !=# 'zsh' && executable('/usr/local/bin/zsh')
  set shell=/usr/local/bin/zsh
endif
" Add -f (--no-rcs) option to use current PATH & GOPATH
set shellcmdflag=-f\ -c
" }}}

" 検索 {{{
set ignorecase " 検索時に大文字・小文字を区別しない
set smartcase  " 検索パターンの大文字・小文字自動認識
set hlsearch   " 検索パターンを強調表示
set incsearch  " インクリメンタルサーチ
" }}}

" 画面表示 {{{
set ambiwidth=single     " 文字幅の指定が曖昧なときは半角と見なす
set showcmd              " コマンド、及び選択範囲の表示
set noshowmode           " 【挿入】【ビジュアル】といった文字列を画面最下段に表示しない
set showmatch            " 対応する括弧を自動的に装飾して表示
set display=truncate     " 画面最下部で切り詰められたら @@@ と表示する
set laststatus=2         " ステータスラインは常に表示
set relativenumber       " 相対行番号を表示する
set number               " 現在行の行番号を表示する
set numberwidth=3        " 行番号の幅は 3 桁
set list                 " 空白の可視化
set listchars=tab:░\ ,trail:␣,eol:⤶,extends:→,precedes:←,nbsp:¯
set showtabline=1        " tabline をタブが 2 つ以上あるときだけ表示する
set colorcolumn=80,140   " 80 桁目、140 桁目をハイライト
set cmdheight=2          " 画面最下段のコマンド表示行数
set cursorline           " カーソルのある行を強調表示する
set shortmess+=c         " 補完時のメッセージをステータスラインに表示しない（echodoc.vim 対策）
set noruler              " ルーラーを表示しない
" }}}

" インデントと整形 {{{
set autoindent          " 自動インデント
set smartindent         " スマートなインデント
set formatoptions+=nmMj " テキスト整形オプション
set wrap                " ウィンドウの幅が足りないときは折り返す
set breakindent         " 折り返し時にインデントする
set showbreak=→\        " 折り返したときに行頭にマークを表示する
set nofixendofline      " 保存時に最終行の改行を修正しない
" 括弧付きの連番を認識する
set formatlistpat=^\\s*\\%(\\d\\+\\\|[-a-z]\\)\\%(\\\ -\\\|[]:.)}\\t]\\)\\?\\s\\+
" }}}

" マウス {{{
set mouse=a                " マウスを全ての場面で使う
if !has('nvim')
  set ttymouse=sgr           " マウスホイールを有効化
  set clipboard=autoselectml " モードレスセレクション時に OS 標準のクリップボードを使う
endif
" }}}

" カラースキーム {{{
" Solarized Light on iTerm2 reports 11;15 for $COLORFGBG
if $COLORFGBG ==# '11;15'
  set background=light
endif

set termguicolors " true color を有効にする
syntax enable
if &background ==# 'light'
  colorscheme solarized8_light
else
  colorscheme nord
endif
" }}}

" タイトル {{{
" タイトル文字列指定
set titlestring=%{delphinus#title#string()}

" ウィンドウタイトルを更新する
if exists('$TMUX')
  set t_ts=k
  set t_fs=\
endif

set title

" Vim が終了したらこのタイトルにする
set titleold=zsh
" }}}

" その他 {{{
set scrolloff=3                   " 上下の画面の端にカーソルを寄せない。
set sidescrolloff=5               " 左右の画面の端にカーソルを寄せない。
set fileformat=unix               " 改行コード指定
set fileformats=unix,dos          " 改行コード自動認識
set backspace=indent,eol,start    " バックスペースを行を超えて有効にする
set grepprg=pt                    " grep コマンドとして pt を使用する
set diffopt=filler,vertical,iwhite " diffコマンド設定
set synmaxcol=0                   " 構文強調表示桁数の制限を解除
set nrformats=                    " 5-5 10進数で数字の上げ下げ
set virtualedit=block             " ビジュアルブロックモードのみ、カーソルを自由移動させる
set updatetime=1000               " スワップファイルが書き込まれるまでの時間。
set wildmenu                      " コマンドラインモードでの補完メニュー
set wildmode=full
set helplang=ja                   " ヘルプは日本語のものを優先する
set lazyredraw                    " 画面描画をできるだけ遅らせる
set matchpairs+=（:）,「:」,【:】,［:］,｛:｝,＜:＞ " `%` で移動するペアを全角文字にも拡張する
set history=1000                  " コマンドライン履歴を 1000 個保存する
set completeopt+=menuone          " 候補が一つだけの時も補完する

let g:autodate_format = '%FT%T%z' " autodate.vim の書式設定
" }}}

" Python 設定 {{{
if !has('nvim')
  set pyxversion=3 " Python3 のみ使う
endif
" }}}

" vim:et:fdm=marker:
