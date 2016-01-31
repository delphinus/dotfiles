scriptencoding utf-8

let g:mapleader='`'

set timeout         " キーのタイムアウト時間設定
set timeoutlen=300
set ttimeoutlen=10

nnoremap <C-D> 3<C-D>
nnoremap <C-U> 3<C-U>
" * 設定
nnoremap * *N
" 水平スクロール
nnoremap gl 8zl
nnoremap gh 8zh
" QuickFix リスト切り替え
nnoremap [w :<C-u>colder<CR>
nnoremap ]w :<C-u>cnewer<CR>
nnoremap [c :<C-u>copen<CR>
nnoremap ]c :<C-u>cclose<CR>
" ウィンドウを最大化する
nnoremap _ <C-W>_
nnoremap # :<C-u>b #<CR>
" タブ移動
nnoremap ( gT
nnoremap ) gt

" https://github.com/mhinz/vim-galore#saner-ctrl-l
nnoremap <leader>l :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>
nnoremap <ESC><ESC> :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>
" https://github.com/mhinz/vim-galore#dont-lose-selection-when-shifting-sidewards
xnoremap <  <gv
xnoremap >  >gv
