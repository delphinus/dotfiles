" シェルの位置を元に戻す
if is_office
    set shell=/bin/sh
elseif is_win
    set shell=$SYSTEMROOT\system32\cmd.exe
endif

"===============================================================================
" NeoBundle 設定開始
"===============================================================================

" プラグイン保存パス
let g:bundle_dir = g:home . '/.vim/bundle'
let g:neobundle_dir = g:bundle_dir . '/neobundle.vim'
let g:after_dir = g:home . '/.vim/after'
let g:mybundle_dir = g:home . '/.vim/mybundle'

" デフォルトプロトコル
let g:neobundle#types#git#default_protocol=g:is_office ? 'ssh' : 'https'

" NeoBundle へのパス
if has('vim_starting')
    set nocompatible               " Be iMproved

    if is_office
        set runtimepath-=$HOME/.vim
    endif
    execute 'set runtimepath+=' . g:neobundle_dir . '/,' . g:after_dir . '/'
endif

" Required:
call neobundle#begin(expand(g:bundle_dir))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Set vimproc
NeoBundle 'Shougo/vimproc', {'build': {
    \   'cygwin': 'make -f make_cygwin.mak',
    \   'mac': 'make -f make_mac.mak',
    \   'unix': 'make -f make_unix.mak',
    \   },
    \ }

" プラグイン（github） {{{
NeoBundle 'Kocha/vim-unite-tig'
NeoBundle 'LeafCage/yankround.vim'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neomru.vim',    {'depends': ['Shougo/unite.vim']}
NeoBundle 'Shougo/unite-outline', {'depends': ['Shougo/unite.vim']}
"NeoBundle 'Shougo/unite-ssh',     {'depends': ['Shougo/unite.vim']}
NeoBundle 'Shougo/vimfiler',      {'depends': ['Shougo/vimproc']}
NeoBundle 'Shougo/vimshell',      {'depends': ['Shougo/vimproc']}
NeoBundle 'Shougo/vinarise.vim'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'airblade/vim-rooter'
NeoBundle 'altercation/vim-colors-solarized'
"NeoBundle 'cocopon/svss.vim'
NeoBundle 'delphinus35/perl-test-base.vim'
NeoBundle 'delphinus35/qfixhowm', 'with-watchdogs'
"NeoBundle 'guns/xterm-color-table.vim'
"NeoBundle 'haya14busa/vim-migemo'
NeoBundle 'houtsnip/vim-emacscommandline'
NeoBundle 'jceb/vim-hier'
"NeoBundle 'junegunn/seoul256.vim'
"NeoBundle 'junegunn/vim-easy-align'
NeoBundle 'kannokanno/unite-dwm'
NeoBundle 'koron/cmigemo'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'mattn/webapi-vim'
"NeoBundle 'morhetz/gruvbox'
NeoBundle 'osyo-manga/shabadou.vim'
NeoBundle 'osyo-manga/unite-qfixhowm'
NeoBundle 'osyo-manga/vim-watchdogs'
NeoBundle 'reedes/vim-colors-pencil'
"NeoBundle 'rking/ag.vim'
"NeoBundle 'sjl/badwolf'
NeoBundle 'spolu/dwm.vim'
NeoBundle 't9md/vim-quickhl'
NeoBundle 't9md/vim-choosewin'
NeoBundle 'thinca/vim-fontzoom'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'thinca/vim-ref'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'tsukkee/unite-tag'
"NeoBundle 'tyru/restart.vim'
"NeoBundle 'ujihisa/unite-colorscheme'
NeoBundle 'vim-jp/vimdoc-ja'
NeoBundle 'vim-scripts/HiColors'
NeoBundle 'vim-scripts/LineJuggler', {'depends': ['vim-scripts/ingo-library']}
"NeoBundle 'vim-scripts/VerticalHelp'
"NeoBundle 'delphinus35/VerticalHelp'
"NeoBundle 'vim-scripts/colorizer'
NeoBundle 'vim-scripts/ingo-library'

" {{{
"NeoBundle 'AndrewRadev/splitjoin.vim'
"NeoBundle 'Rykka/trans.vim'
"NeoBundle 'Shougo/neosnippet'
"NeoBundle 'amdt/sunset'
"NeoBundle 'bcat/abbott.vim'
"NeoBundle 'bling/vim-bufferline'
"NeoBundle 'chikatoike/activefix.vim'
"NeoBundle 'chreekat/vim-paren-crosshairs'
"NeoBundle 'dannyob/quickfixstatus'
"NeoBundle 'delphinus35/activefix.vim'
"NeoBundle 'delphinus35/clam.vim'
"NeoBundle 'delphinus35/unite-converter-erase-diff-buffer'
"NeoBundle 'delphinus35/vim-pastefire'
"NeoBundle 'drmikehenry/vim-fixkey'
"NeoBundle 'fbueno/cospe.vim'
"NeoBundle 'fuenor/vim-make-syntax'
"NeoBundle 'gcmt/breeze.vim'
"NeoBundle 'gcmt/plum.vim'
"NeoBundle 'gcmt/psearch.vim'
"NeoBundle 'gcmt/taboo.vim'
"NeoBundle 'godlygeek/csapprox'
"NeoBundle 'gokcehan/vim-yacom'
"NeoBundle 'goldfeld/vim-seek'
"NeoBundle 'gregsexton/gitv'
"NeoBundle 'hobbestigrou/vimtips-fortune'
"NeoBundle 'int3/vim-extradite'
"NeoBundle 'itchyny/thumbnail.vim'
"NeoBundle 'jelera/vim-gummybears-colorscheme'
"NeoBundle 'jnurmine/Zenburn'
"NeoBundle 'joonty/vdebug'
"NeoBundle 'justinmk/vim-sneak'
"NeoBundle 'kana/vim-textobj-indent'
"NeoBundle 'kana/vim-textobj-user'
"NeoBundle 'khorser/vim-qfnotes'
"NeoBundle 'koron/chalice'
"NeoBundle 'kshenoy/vim-origami'
"NeoBundle 'mattn/gist-vim'
"NeoBundle 'matze/vim-move'
"NeoBundle 'mihaifm/bck'
"NeoBundle 'nathanaelkane/vim-indent-guides'
"NeoBundle 'noahfrederick/Hemisu'
"NeoBundle 'osyo-manga/vim-anzu'
"NeoBundle 'othree/javascript-libraries-syntax.vim'
"NeoBundle 'rainux/vim-desert-warm-256'
"NeoBundle 'rhysd/clever-f.vim'
"NeoBundle 'rkitover/perl-vim-mxd'
"NeoBundle 'roman/golden-ratio'
"NeoBundle 'scrooloose/nerdtree'
"NeoBundle 'scrooloose/syntastic'
"NeoBundle 'sjl/clam.vim'
"NeoBundle 'terryma/vim-expand-region'
"NeoBundle 'terryma/vim-multiple-cursors'
"NeoBundle 'thinca/vim-visualstar'
"NeoBundle 'thinca/vim-tabrecent'
"NeoBundle 'tomtom/tinykeymap_vim'
"NeoBundle 'tpope/vim-characterize'
"NeoBundle 'tpope/vim-eunuch'
"NeoBundle 'tpope/vim-sleuth'
"NeoBundle 'troydm/asyncfinder.vim'
"NeoBundle 'troydm/easybuffer.vim'
"NeoBundle 'tyru/current-func-info.vim'
"NeoBundle 'vim-scripts/Align'
"NeoBundle 'vim-scripts/Colour-Sampler-Pack'
"NeoBundle 'vim-scripts/DrawIt'
"NeoBundle 'vim-scripts/ExplainPattern'
"NeoBundle 'vim-scripts/ZoomWin'
"NeoBundle 'vim-scripts/cmdline-completion'
"NeoBundle 'vim-scripts/sudo.vim'
"NeoBundle 'vim-scripts/vmark.vim--Visual-Bookmarking'
"NeoBundle 'w0ng/vim-hybrid'
"NeoBundle 'ynkdir/vim-funlib'
"NeoBundle 'yuratomo/gmail.vim'
" }}}
" }}}

NeoBundleLazy 'delphinus35/lcpeek.vim', {'autoload': {'command': 'PeekInput'}}
NeoBundleLazy 'fuenor/JpFormat.vim', {'autoload': {'command': 'JpFormat'}}
NeoBundleLazy 'gregsexton/VimCalc', {'autoload': {'command': 'Calc'}}
NeoBundleLazy 'jelera/vim-javascript-syntax', {'autoload': {'filetypes': 'javascript'}}
NeoBundleLazy 'sjl/gundo.vim', {'autoload': {'command': 'GundoToggle'}}
NeoBundleLazy 'tyru/capture.vim', {'autoload': {'command': 'Capture'}}
NeoBundleLazy 'vim-perl/vim-perl', {'autoload': {'filetypes': 'perl'}}
NeoBundleLazy 'catalinciurea/perl-nextmethod', {'autoload': {'filetypes': 'perl'}}
NeoBundleLazy 'c9s/perlomni.vim', {'autoload': {'filetypes': 'perl'}}
NeoBundleLazy 'ChrisYip/Better-CSS-Syntax-for-Vim', {'autoload': {'filetypes': 'css'}}
NeoBundleLazy 'csv.vim', {'autoload': {'filetypes': 'csv'}}

" vimpager
NeoBundleLazy 'rkitover/vimpager'

" TweetVim
NeoBundleLazy 'basyura/TweetVim', {'depends': [
    \   'basyura/bitly.vim',
    \   'basyura/twibill.vim',
    \   'tyru/open-browser.vim',
    \ ],
    \ 'autoload': {'commands': 'TweetVimHomeTimeLine'}}

NeoBundleLazy 'delphinus35/chalice', {'autoload': {'commands': 'Chalice'}}

" Mac 専用
if has('macunix')
    NeoBundle 'msanders/cocoa.vim'
    NeoBundle 'troydm/pb.vim'
else
    NeoBundleLazy 'msanders/cocoa.vim'
    NeoBundleLazy 'troydm/pb.vim'
endif

" github にないプラグイン
command! -nargs=1
            \ MyNeoBundle
            \ NeoBundle <args>, {
            \   'base': g:mybundle_dir,
            \   'type': 'nosync',
            \   'lazy': 1,
            \ }

MyNeoBundle 'briofita'

if has('vim_starting')
    if is_win
        set runtimepath+=~/vimfiles/
    elseif is_remora || is_office_cygwin
        set runtimepath+=~/.vim/
    elseif is_office
        set runtimepath^=$H/.vim/
    endif
endif

call neobundle#end()

filetype plugin indent on
syntax on
NeoBundleCheck

" vim:se et fdm=marker:
