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
" ウィンドウを最大化する
nnoremap _ <C-W>_

nnoremap <ESC><ESC> :nohlsearch<cr>

" For QuickFix
nnoremap qn :cnext<CR>
nnoremap qp :cprev<CR>

" view で起動したときは q で終了
augroup SetMappingForView
  autocmd!
  autocmd VimEnter * if &readonly | nnoremap q :<C-u>qa<CR> | endif
augroup END

" オリジナル関数のマッピング
nmap Y <Plug>DelphinusFsshCopy

" When editing a file, always jump to the last known cursor position. Don't do
" it when the position is invalid or when inside an event handler (happens
" when dropping a file on gvim).
function s:jump_to_last_pos() abort
  let last_pos = line("'\"")
  if last_pos >= 1 && last_pos <= line('$')
    execute 'normal! g`"'
  endif
endfunction

augroup JumpToTheLastPosition
  autocmd!
  autocmd BufReadPost * call <SID>jump_to_last_pos()
augroup END

" The native implementation of vim-higlihghtedyank in NeoVim
" ( https://github.com/machakann/vim-highlightedyank )
if has('nvim')
  augroup HighlightedYank
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
  augroup END
endif
