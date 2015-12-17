scriptencoding utf-8

let mapleader='`'

set timeout         " キーのタイムアウト時間設定
set timeoutlen=300
set ttimeoutlen=10

nnoremap <C-D> 3<C-D>
nnoremap <C-U> 3<C-U>
"Escの2回押しでハイライト消去
nmap <ESC><ESC> :nohlsearch<CR><ESC>
" * 設定
nnoremap * *N
" 水平スクロール
nnoremap gl 8zl
nnoremap gh 8zh
" omini 補完起動
inoremap <C-O> <C-X><C-O>
" QuickFix リスト切り替え
nnoremap [w :<C-u>colder<CR>
nnoremap ]w :<C-u>cnewer<CR>
" ウィンドウを最大化する
nnoremap _ <C-W>_
nnoremap # :<C-u>b #<CR>
" タブ移動
nnoremap ( gT
nnoremap ) gt
