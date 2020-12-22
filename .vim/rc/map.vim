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

" https://twitter.com/uvrub/status/1341036672364945408
inoremap <silent> <CR> <C-g>u<CR>

" For QuickFix / Location List
function! s:qf_or_loc(cmd) abort
  " https://vi.stackexchange.com/questions/18079/how-to-check-whether-the-location-list-for-the-current-window-is-open
  let is_loc = get(getloclist(0, {'winid': 0}), 'winid', 0)
  let prefix = is_loc ? 'l' : 'c'
  let cmd = ':' . prefix . a:cmd
  echo cmd
  try
    execute cmd
  catch /E553:/
  catch /E42:/
  endtry
endfunction
nnoremap qn :call <SID>qf_or_loc('next')<CR>
nnoremap qp :call <SID>qf_or_loc('prev')<CR>
nnoremap qq :call <SID>qf_or_loc('close')<CR>

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
