let mapleader='`'

set timeout         " キーのタイムアウト時間設定
set timeoutlen=300
set ttimeoutlen=10

nnoremap <C-D> 3<C-D>
nnoremap <C-U> 3<C-U>
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
map * <Plug>(visualstar-*)N
" IMEがONの時IMEをOFFにしてfコマンド実行
nnoremap <silent> f :set iminsert=0<CR>f
nnoremap <silent> F :set iminsert=0<CR>F
" 水平スクロール
nnoremap <Tab>l 8zl
nnoremap <Tab>h 8zh
" 4-6
"nnoremap <silent> cy ce<C-R>0<ESC>:let@/=@1<CR>:noh<CR>
"vnoremap <silent> cy c<C-R>0<ESC>:let@/=@1<CR>:noh<CR>
"nnoremap <silent> ciy ciw<C-R>0<ESC>:let@/=@1<CR>:noh<CR>
" omini 補完起動
inoremap <C-O> <C-X><C-O>

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
call <SID>MapFastKeycode('<M-S-p>', "\eP")
call <SID>MapFastKeycode('<M-n>', "\en")
call <SID>MapFastKeycode('<M-S-n>', "\eN")
call <SID>MapFastKeycode('<M-q>', "\eq")
call <SID>MapFastKeycode('<M-S-q>', "\eQ")
call <SID>MapFastKeycode('<M-t>', "\et")
call <SID>MapFastKeycode('<M-S-t>', "\eT")

"-----------------------------------------------------------------------------
" ヘルプ
autocmd FileType help nnoremap <buffer>q :q<CR>
