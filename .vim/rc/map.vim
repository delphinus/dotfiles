let mapleader='`'

nnoremap <M-f> gt
nnoremap <M-b> gT
nnoremap <M-S-f> :tabm +1<CR>
nnoremap <M-S-b> :tabm -1<CR>
nnoremap <F1> :mak!<CR>
nnoremap <F2> :QFix<CR>
nnoremap k gk
nnoremap j gj
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

" Alt キーを Meta キーとして使う
if !has('gui_running')
    let alt_keys=['b', 'f', 'p']
    for k in alt_keys
        execute "set <M-" . k . ">=<ESC>" . k
        execute "nmap <ESC>" . k . " <M-" . k . ">"
        execute "set <M-S-" . k . ">=<ESC>" . toupper(k)
        execute "nmap <ESC>" . toupper(k) . " <M-S-" . k . ">"
    endfor
endif
