set encoding=utf-8     " internal encoding
scriptencoding utf-8

" エンコーディング {{{
set termencoding=utf-8 " ターミナルのエンコーディング
set fileencoding=utf-8 " 新規ファイルのエンコーディング
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
set undofile             " アンドゥファイルを保存する
set dir=/tmp
set backupdir=/tmp
set undodir=/tmp
let &backupskip = '/private/tmp/*,' . &backupskip " Mac で crontab を使うための設定
set path+=lib,app/lib " gf, gF, CTRL-W_f でファイルを開くときに検索するパス
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
set formatoptions+=nmM " テキスト整形オプション
" 括弧付きの連番を認識する
set formatlistpat=^\\s*\\%(\\d\\+\\\|[-a-z]\\)\\%(\\\ -\\\|[]:.)}\\t]\\)\\?\\s\\+
" }}}

" 画面表示 {{{
set ambiwidth=single     " 文字幅の指定が曖昧なときは半角と見なす
set t_Co=256             " 256 色表示ターミナル対応
set showcmd              " コマンド、及び選択範囲の表示
set noshowmode           " 【挿入】【ビジュアル】といった文字列を画面最下段に表示しない
set showmatch            " 対応する括弧を自動的に装飾して表示
set display=uhex         " 画面最下行もできるだけ表示する
                         " 又、非表示文字を 16 進数で表示する
set laststatus=2         " ステータスラインは常に表示
set relativenumber       " 相対行番号を表示する
set number               " 現在行の行番号を表示する
set numberwidth=3        " 行番号の幅は 3 桁
set list                 " 空白の可視化
set listchars=tab:›\ ,trail:␣,eol:჻,extends:»,precedes:«,nbsp:¯
set wrap                 " ウィンドウの幅が足りないときは折り返す
set breakindent          " 折り返し時にインデントする
set showbreak=         " 折り返したときに行頭にマークを表示する
set showtabline=1        " tabline をタブが 2 つ以上あるときだけ表示する
execute 'set colorcolumn=' . join(range(141, 9999), ',')
" 141 桁目より後をハイライト
noremap <Plug>(ToggleColorColumn)
      \ :<c-u>let &colorcolumn = len(&colorcolumn) > 0 ? '' :
      \   join(range(141, 9999), ',')<CR>
nmap <Leader>cc <Plug>(ToggleColorColumn)

set cmdheight=2          " 画面最下段のコマンド表示行数
" }}}

" マウス {{{
set mouse=a                " マウスを全ての場面で使う
set ttymouse=sgr           " マウスホイールを有効化
set clipboard=autoselectml " モードレスセレクション時に OS 標準のクリップボードを使う
" }}}

set scrolloff=3                   " 上下の画面の端にカーソルを寄せない。
set sidescrolloff=5               " 左右の画面の端にカーソルを寄せない。

set fileformat=unix               " 改行コード指定
set fileformats=unix,dos          " 改行コード自動認識

set backspace=indent,eol,start    " バックスペースを行を超えて有効にする

set grepprg=pt                    " grep コマンドとして pt を使用する

set diffopt=filler,vertical,iwhite " diffコマンド設定

set synmaxcol=0                   " 構文強調表示桁数の制限を解除

set notagbsearch                  " unite.vim + 日本語ヘルプでフリーズするときの対策

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
set completeopt-=preview          " プレビューウィンドウへの表示をやめる

colorscheme base16-ateliersulphurpool
set background=dark

augroup SetCommentItalic
  autocmd!
  autocmd VimEnter * highlight Comment cterm=italic
  autocmd VimEnter * highlight htmlItalic cterm=italic
  autocmd VimEnter * highlight htmlBold cterm=bold
  autocmd VimEnter * highlight htmlBoldItalic cterm=bold,italic
augroup END

augroup SetSearchColor
  autocmd!
  autocmd VimEnter * hi! link Search IncSearch
augroup END

" vim:et:fdm=marker:
