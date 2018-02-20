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
" タブ移動
nnoremap ( gT
nnoremap ) gt

" https://github.com/mhinz/vim-galore#saner-ctrl-l
nnoremap <ESC><ESC> :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>

" view で起動したときは q で終了
augroup SetMappingForView
  autocmd!
  autocmd VimEnter * if &readonly | nnoremap q :<C-u>qa<CR> | endif
augroup END

" オリジナル関数のマッピング
nmap Y <Plug>DelphinusFsshCopy

if !dein#tap('deol.nvim') && !has('nvim')
  set termkey=<A-w>
  " open terminal in new window (<C-N> should be mapped to <Plug>DWMNew)
  nmap <C-\><C-N> <C-N>:terminal ++close ++curwin<cr><A-w>:silent set nonumber norelativenumber nolist colorcolumn=0<cr>
endif

if &shell !=# 'zsh'
  if executable('/usr/local/bin/zsh')
    set shell=/usr/local/bin/zsh
  endif
endif
