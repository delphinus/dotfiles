scriptencoding utf-8

let g:mapleader='`'

set timeout         " キーのタイムアウト時間設定
set timeoutlen=300
set ttimeoutlen=10

nnoremap <C-D> 3<C-D>
vnoremap <C-D> 3<C-D>
nnoremap <C-U> 3<C-U>
vnoremap <C-U> 3<C-U>
" * 設定
nnoremap * *N
" QuickFix リスト切り替え
nnoremap [w :<C-u>colder<CR>
nnoremap ]w :<C-u>cnewer<CR>
nnoremap [C :<C-u>copen<CR>
nnoremap ]C :<C-u>cclose<CR>
" ウィンドウを最大化する
nnoremap _ <C-W>_

nnoremap <ESC><ESC> :nohlsearch<cr>

" view で起動したときは q で終了
augroup SetMappingForView
  autocmd!
  autocmd VimEnter * if &readonly | nnoremap q :<C-u>qa<CR> | endif
augroup END

" オリジナル関数のマッピング
nmap Y <Plug>DelphinusFsshCopy
