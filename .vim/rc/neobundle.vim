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
NeoBundle 'Shougo/vimproc.vim', {'build': {
    \   'cygwin': 'make -f make_cygwin.mak',
    \   'mac': 'make -f make_mac.mak',
    \   'unix': 'make -f make_unix.mak',
    \   },
    \ }

" プラグイン（github） {{{
NeoBundle 'Kocha/vim-unite-tig',          {'depends': ['Shougo/unite.vim']}
NeoBundle 'Shougo/neomru.vim',            {'depends': ['Shougo/unite.vim']}
NeoBundle 'Shougo/unite-outline',         {'depends': ['Shougo/unite.vim']}
NeoBundle 'hakobe/unite-script-examples', {'depends': ['Shougo/unite.vim']}
NeoBundle 'kannokanno/unite-dwm',         {'depends': ['Shougo/unite.vim', 'spolu/dwm.vim']}
NeoBundle 'osyo-manga/unite-qfixhowm',    {'depends': ['Shougo/unite.vim']}
NeoBundle 'rhysd/unite-ruby-require.vim', {'depends': ['Shougo/unite.vim']}
NeoBundle 'tsukkee/unite-tag',            {'depends': ['Shougo/unite.vim']}

NeoBundle 'Shougo/vimfiler',              {'depends': ['Shougo/vimproc.vim']}
NeoBundle 'Shougo/vimshell',              {'depends': ['Shougo/vimproc.vim']}
NeoBundle 'osyo-manga/vim-watchdogs',     {'depends': [
            \   'Shougo/vimproc.vim',
            \   'dannyob/quickfixstatus',
            \   'cohama/vim-hier',
            \   'osyo-manga/shabadou.vim',
            \   'thinca/vim-quickrun',
            \ ]}

NeoBundle 'LeafCage/yankround.vim'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vinarise.vim'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'airblade/vim-rooter'
"NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'blueyed/vim-colors-solarized'
NeoBundle 'amdt/sunset'
NeoBundle 'delphinus35/qfixhowm', 'with-watchdogs'
NeoBundle 'fuenor/JpFormat.vim'
NeoBundle 'houtsnip/vim-emacscommandline'
NeoBundle 'junegunn/vim-easy-align'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'koron/cmigemo'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'mattn/webapi-vim'
NeoBundle 'morhetz/gruvbox'
NeoBundle 'motemen/xslate-vim'
NeoBundle 'nishigori/increment-activator'
NeoBundle 'reedes/vim-colors-pencil'
NeoBundle 'rhysd/neco-ruby-keyword-args', { 'depends': ['Shougo/neocomplete']}
NeoBundle 'rhysd/vim-textobj-ruby',       { 'depends': ['kana/vim-textobj-user']}
NeoBundle 't9md/vim-quickhl'
NeoBundle 't9md/vim-choosewin'
NeoBundle 'thinca/vim-fontzoom'
NeoBundle 'thinca/vim-ref'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-rails'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-repeat'
"NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'delphinus35/vim-unimpaired'
NeoBundle 'vim-jp/vimdoc-ja'
NeoBundle 'vim-scripts/HiColors'
NeoBundle 'vim-scripts/LineJuggler', {'depends': ['vim-scripts/ingo-library']}
NeoBundle 'vim-scripts/nginx.vim'
NeoBundle 'vim-scripts/visualrepeat'

" {{{
"NeoBundle 'AndrewRadev/splitjoin.vim'
"NeoBundle 'Rykka/trans.vim'
"NeoBundle 'Shougo/neosnippet'
"NeoBundle 'Shougo/unite-ssh',     {'depends': ['Shougo/unite.vim']}
"NeoBundle 'amdt/sunset'
"NeoBundle 'bcat/abbott.vim'
"NeoBundle 'bling/vim-bufferline'
"NeoBundle 'chikatoike/activefix.vim'
"NeoBundle 'chreekat/vim-paren-crosshairs'
"NeoBundle 'cocopon/svss.vim'
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
"NeoBundle 'guns/xterm-color-table.vim'
"NeoBundle 'haya14busa/vim-migemo'
"NeoBundle 'hobbestigrou/vimtips-fortune'
"NeoBundle 'int3/vim-extradite'
"NeoBundle 'itchyny/thumbnail.vim'
"NeoBundle 'jelera/vim-gummybears-colorscheme'
"NeoBundle 'junegunn/seoul256.vim'
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
"NeoBundle 'rking/ag.vim'
"NeoBundle 'rkitover/perl-vim-mxd'
"NeoBundle 'roman/golden-ratio'
"NeoBundle 'scrooloose/nerdtree'
"NeoBundle 'scrooloose/syntastic'
"NeoBundle 'sjl/badwolf'
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
"NeoBundle 'tyru/restart.vim'
"NeoBundle 'ujihisa/unite-colorscheme'
"NeoBundle 'vim-scripts/Align'
"NeoBundle 'vim-scripts/Colour-Sampler-Pack'
"NeoBundle 'vim-scripts/DrawIt'
"NeoBundle 'vim-scripts/ExplainPattern'
"NeoBundle 'vim-scripts/VerticalHelp'
"NeoBundle 'vim-scripts/ZoomWin'
"NeoBundle 'vim-scripts/cmdline-completion'
"NeoBundle 'vim-scripts/colorizer'
"NeoBundle 'vim-scripts/sudo.vim'
"NeoBundle 'vim-scripts/vmark.vim--Visual-Bookmarking'
"NeoBundle 'w0ng/vim-hybrid'
"NeoBundle 'ynkdir/vim-funlib'
"NeoBundle 'yuratomo/gmail.vim'
" }}}
" }}}

NeoBundleLazy 'delphinus35/lcpeek.vim',
            \ {'autoload': {'commands': ['PeekInput']}}
NeoBundleLazy 'delphinus35/perl-test-base.vim',
            \ {'autoload': {'filetypes': ['perl']}}
NeoBundleLazy 'gregsexton/VimCalc',
            \ {'autoload': {'commands': ['Calc']}}
NeoBundleLazy 'jelera/vim-javascript-syntax',
            \ {'autoload': {'filetypes': ['javascript']}}
NeoBundleLazy 'sjl/gundo.vim',
            \ {'autoload': {'commands': ['GundoToggle']}}
NeoBundleLazy 'tyru/capture.vim',
            \ {'autoload': {'commands': ['Capture']}}
NeoBundleLazy 'vim-perl/vim-perl',
            \ {'autoload': {'filetypes': ['perl']}}
NeoBundleLazy 'catalinciurea/perl-nextmethod',
            \ {'autoload': {'filetypes': ['perl']}}
NeoBundleLazy 'c9s/perlomni.vim',
            \ {'autoload': {'filetypes': ['perl']}}
NeoBundleLazy 'ChrisYip/Better-CSS-Syntax-for-Vim',
            \ {'autoload': {'filetypes': ['css']}}
NeoBundleLazy 'csv.vim',
            \ {'autoload': {'filetypes': ['csv']}}

" vimpager
NeoBundleLazy 'rkitover/vimpager'

" TweetVim
NeoBundleLazy 'basyura/TweetVim', {'depends': [
    \   'basyura/bitly.vim',
    \   'basyura/twibill.vim',
    \   'tyru/open-browser.vim',
    \ ],
    \ 'autoload': {'commands': 'TweetVimHomeTimeLine'}}

NeoBundleLazy 'delphinus35/chalice', {'autoload': {'commands': ['Chalice']}}

" Mac 専用
if has('macunix')
    NeoBundle 'msanders/cocoa.vim'
    NeoBundle 'troydm/pb.vim'
    NeoBundle 'rizzatti/dash.vim'
    NeoBundle 'ryutorion/vim-itunes'
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
