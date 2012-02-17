let mapleader='`'

nnoremap <Leader>f :VimFiler<CR>
nnoremap <F12> :VimFiler<CR>
"nnoremap <Leader>t :TlistToggle<CR>
"nnoremap <Leader>T :TlistUpdate<CR>
"nnoremap <C-X><C-N> gt
"nnoremap <C-X><C-P> gT
nnoremap <C-X><C-F> :tabm +1<CR>
nnoremap <C-X><C-B> :tabm -1<CR>
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
"cnoremap <C-F> <Right>
"cnoremap <C-B> <Left>
"cnoremap <C-A> <Home>
"cnoremap <C-E> <End>
"cnoremap <ESC>f <C-Right>
"cnoremap <ESC>b <C-Left>
inoremap # X#
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
