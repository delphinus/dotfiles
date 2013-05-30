" シェルの位置を元に戻す
if is_office
    set shell=/bin/sh
elseif is_office_win
    set shell=$SYSTEMROOT\system32\cmd.exe
endif

" NeoBundle 設定開始
set nocompatible


filetype off

" プラグイン保存パス
let g:bundle_dir = g:vim_home . '/bundle'
let g:neobundle_dir = g:vim_home .'/neobundle'

" デフォルトプロトコル
let g:neobundle#types#git#default_protocol='https'

" ディレクトリが存在しなければ作成
if ! isdirectory(g:bundle_dir)
    call mkdir(g:bundle_dir)
endif

" NeoBundle へのパス
if has('vim_starting')
    if is_office
        set runtimepath-=$HOME/.vim
    endif
    execute 'set runtimepath+=' . g:neobundle_dir
endif

call neobundle#rc(g:bundle_dir)
execute 'helptags ' . g:neobundle_dir . '/doc'

" プラグイン（github） {{{
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'airblade/vim-rooter'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'AndrewRadev/splitjoin.vim'
NeoBundle 'bcat/abbott.vim'
NeoBundle 'bling/vim-bufferline'
NeoBundle 'chreekat/vim-paren-crosshairs'
"NeoBundle 'chikatoike/activefix.vim'
"NeoBundle 'delphinus35/activefix.vim'
"NeoBundle 'dannyob/quickfixstatus'
"NeoBundle 'delphinus35/vim-pastefire'
NeoBundle 'delphinus35/unite-converter-erase-diff-buffer'
"NeoBundle 'fbueno/cospe.vim'
NeoBundle 'fuenor/qfixhowm'
"NeoBundle 'fuenor/vim-make-syntax'
NeoBundle 'fuenor/JpFormat.vim'
"NeoBundle 'gcmt/breeze.vim'
NeoBundle 'gcmt/psearch.vim'
"NeoBundle 'gcmt/taboo.vim'
"NeoBundle 'godlygeek/csapprox'
NeoBundle 'gokcehan/vim-yacom'
NeoBundle 'goldfeld/vim-seek'
NeoBundle 'guns/xterm-color-table.vim'
NeoBundle 'gregsexton/gitv'
NeoBundle 'gregsexton/VimCalc'
"NeoBundle 'hobbestigrou/vimtips-fortune'
NeoBundle 'houtsnip/vim-emacscommandline'
"NeoBundle 'int3/vim-extradite'
NeoBundle 'itchyny/thumbnail.vim'
NeoBundle 'jceb/vim-hier'
NeoBundle 'jelera/vim-gummybears-colorscheme'
"NeoBundle 'joonty/vdebug'
NeoBundle 'jnurmine/Zenburn'
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kana/vim-textobj-indent'
NeoBundle 'kannokanno/unite-dwm'
"NeoBundle 'khorser/vim-qfnotes'
"NeoBundle 'koron/chalice'
NeoBundle 'Lokaltog/vim-easymotion'
"NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'noahfrederick/Hemisu'
NeoBundle 'mattn/gist-vim'
NeoBundle 'mattn/webapi-vim'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'maxbrunsfeld/vim-yankstack'
"NeoBundle 'mihaifm/bck'
NeoBundle 'mileszs/ack.vim'
NeoBundle 'morhetz/gruvbox'
NeoBundle 'osyo-manga/shabadou.vim'
NeoBundle 'osyo-manga/unite-qfixhowm'
NeoBundle 'osyo-manga/vim-watchdogs'
NeoBundle 'othree/javascript-libraries-syntax.vim'
NeoBundle 'rainux/vim-desert-warm-256'
"NeoBundle 'Rykka/trans.vim'
"NeoBundle 'roman/golden-ratio'
"NeoBundle 'scrooloose/syntastic'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimfiler'
NeoBundle 'Shougo/vimproc', {'build': {
    \   'cygwin': 'make -f make_cygwin.mak',
    \   'mac': 'make -f make_mac.mak',
    \   'unix': 'make -f make_unix.mak',
    \   },
    \ }
NeoBundle 'Shougo/vimshell'
"NeoBundle 'Shougo/neocomplcache'
"NeoBundle 'Shougo/neosnippet'
NeoBundle 'h1mesuke/unite-outline'
NeoBundle 'sjl/badwolf'
"NeoBundle 'sjl/clam.vim'
NeoBundle 'delphinus35/clam.vim'
NeoBundle 'sjl/gundo.vim'
NeoBundle 'spolu/dwm.vim'
NeoBundle 'terryma/vim-expand-region'
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'thinca/vim-ref'
NeoBundle 'thinca/vim-tabrecent'
NeoBundle 'thinca/vim-visualstar'
"NeoBundle 'tomtom/tinykeymap_vim'
NeoBundle 'tpope/vim-characterize'
NeoBundle 'tpope/vim-eunuch'
NeoBundle 'tpope/vim-fugitive'
"NeoBundle 'tpope/vim-sleuth'
NeoBundle 'tpope/vim-unimpaired'
"NeoBundle 'amdt/sunset'
"NeoBundle 'troydm/asyncfinder.vim'
NeoBundle 'troydm/easybuffer.vim'
NeoBundle 'tyru/current-func-info.vim'
NeoBundle 'ujihisa/unite-colorscheme'
NeoBundle 'vim-jp/vimdoc-ja'
NeoBundle 'vim-scripts/cmdline-completion'
NeoBundle 'vim-scripts/colorizer'
NeoBundle 'vim-scripts/Colour-Sampler-Pack'
NeoBundle 'vim-scripts/DrawIt'
NeoBundle 'vim-scripts/ExplainPattern'
NeoBundle 'vim-scripts/HiColors'
NeoBundle 'vim-scripts/LineJuggler'
NeoBundle 'vim-scripts/sudo.vim'
NeoBundle 'vim-scripts/vim-align'
NeoBundle 'vim-scripts/vmark.vim--Visual-Bookmarking'
"NeoBundle 'vim-scripts/ZoomWin'
"NeoBundle 'ynkdir/vim-funlib'
NeoBundle 'yuratomo/gmail.vim'
" }}}

" 後で読み込む {{{
NeoBundleLazy 'rkitover/vimpager'
NeoBundleLazy 'scrooloose/nerdtree'

" Mac 専用
if has('macunix')
    NeoBundle 'msanders/cocoa.vim'
    NeoBundle 'troydm/pb.vim'
else
    NeoBundleLazy 'msanders/cocoa.vim'
    NeoBundleLazy 'troydm/pb.vim'
endif

" CSS
NeoBundleLazy 'ChrisYip/Better-CSS-Syntax-for-Vim'
autocmd FileType css NeoBundleSource Better-CSS-Syntax-for-Vim

" CSV
NeoBundleLazy 'csv.vim'
autocmd FileType csv NeoBundleSource csv.vim

" Perl
NeoBundleLazy 'c9s/perlomni.vim'
NeoBundleLazy 'rkitover/perl-vim-mxd'
"NeoBundleLazy 'petdance/vim-perl'
function s:open_perl()
    NeoBundleSource perlomni
    NeoBundleSource perl-vim-mxd
endfunction
autocmd FileType perl call s:open_perl()

" Chalice
NeoBundleLazy 'delphinus35/chalice'
command! EnableChalice :NeoBundleSource chalice

" Twitter
NeoBundleLazy 'basyura/TweetVim', {'depends': [
    \   'basyura/bitly.vim',
    \   'basyura/twibill.vim',
    \   'tyru/open-browser.vim',
    \ ]}
command! EnableTwitter :NeoBundleSource TweetVim
" }}}

filetype plugin indent on

if has('vim_starting')
    if is_remora || is_office_win || is_office_cygwin
        set runtimepath+=~/.vim/
    elseif is_office
        set runtimepath^=$H/.vim/
    endif
endif

syntax on

" vim:se et fdm=marker:
