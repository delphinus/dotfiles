scriptencoding utf-8

let mapleader='`'

set timeout         " キーのタイムアウト時間設定
set timeoutlen=300
set ttimeoutlen=10

nnoremap <C-D> 3<C-D>
nnoremap <C-U> 3<C-U>
" j 2 回で ESC
inoremap jj <Esc>
" k 2 回で ESC
inoremap kk <Esc>
" Mac OSXでのvim環境整理。.vimrcやらオヌヌメPlug inやらまとめ。
" http://d.hatena.ne.jp/yuroyoro/20101104/1288879591
"Escの2回押しでハイライト消去
nmap <ESC><ESC> :nohlsearch<CR><ESC>
" * 設定
nnoremap * *N
" 水平スクロール
nnoremap gl 8zl
nnoremap gh 8zh
" 4-6
"nnoremap <silent> cy ce<C-R>0<ESC>:let@/=@1<CR>:noh<CR>
"vnoremap <silent> cy c<C-R>0<ESC>:let@/=@1<CR>:noh<CR>
"nnoremap <silent> ciy ciw<C-R>0<ESC>:let@/=@1<CR>:noh<CR>
" omini 補完起動
inoremap <C-O> <C-X><C-O>
" QuickFix リスト切り替え
nnoremap [w :<C-u>colder<CR>
nnoremap ]w :<C-u>cnewer<CR>
" ウィンドウを最大化する
nnoremap _ <C-W>_
nnoremap # :<C-u>b #<CR>
