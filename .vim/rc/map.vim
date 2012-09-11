let mapleader='`'

nnoremap <M-x> gt
nnoremap <M-z> gT
nnoremap <S-M-x> :tabm +1<CR>
nnoremap <S-M-z> :tabm -1<CR>
nnoremap <F1> :mak!<CR>
nnoremap <F2> :QFix<CR>
nnoremap <C-D> 3<C-D>
nnoremap <C-U> 3<C-U>
nnoremap <C-Z> <C-^>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <S-CR> :simalt ~x<CR>
nnoremap <C-CR> :simalt ~r<CR>
nnoremap <S-C-CR> :simalt ~n<CR>
inoremap # X#
" j 2 回で ESC
inoremap jj <Esc>
" k 2 回で ESC
inoremap kk <Esc>
" Gundo
nnoremap <F5> :GundoToggle<CR>
" Mac OSXでのvim環境整理。.vimrcやらオヌヌメPlug inやらまとめ。
" http://d.hatena.ne.jp/yuroyoro/20101104/1288879591
"Escの2回押しでハイライト消去
nmap <ESC><ESC> ;nohlsearch<CR><ESC>
" ;でコマンド入力( ;と:を入れ替)
noremap ; :
noremap : ;
" * 設定
nnoremap * *N
nnoremap # #N
map * <Plug>(visualstar-*)N
map # <Plug>(visualstar-#)N
" IMEがONの時IMEをOFFにしてfコマンド実行
nnoremap <silent> f :set iminsert=0<CR>f
nnoremap <silent> F :set iminsert=0<CR>F
" 4-6
"nnoremap <silent> cy ce<C-R>0<ESC>:let@/=@1<CR>:noh<CR>
"vnoremap <silent> cy c<C-R>0<ESC>:let@/=@1<CR>:noh<CR>
"nnoremap <silent> ciy ciw<C-R>0<ESC>:let@/=@1<CR>:noh<CR>

" http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim
" MapFastKeycode: helper for fast keycode mappings
" makes use of unused vim keycodes <[S-]F15> to <[S-]F37>
function! <SID>MapFastKeycode(key, keycode)
    if s:fast_i == 46
        echohl WarningMsg
        echomsg "Unable to map ".a:key.": out of spare keycodes"
        echohl None
        return
    endif
    let vkeycode = '<'.(s:fast_i/23==0 ? '' : 'S-').'F'.(15+s:fast_i%23).'>'
    exec 'set '.vkeycode.'='.a:keycode
    exec 'map '.vkeycode.' '.a:key
    let s:fast_i += 1
endfunction
let s:fast_i = 0

call <SID>MapFastKeycode('<M-p>', "\ep")
call <SID>MapFastKeycode('<M-x>', "\ex")
call <SID>MapFastKeycode('<M-z>', "\ez")
call <SID>MapFastKeycode('<M-t>', "\et")
