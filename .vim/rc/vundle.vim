" シェルの位置を元に戻す
if is_office
	set shell=/bin/sh
elseif is_office_win
	set shell=$SYSTEMROOT\system32\cmd.exe
endif

set nocompatible
filetype off

if is_remora || is_office_cygwin || is_backup
	set rtp+=~/.vim/vundle
elseif is_office 
	set rtp-=$HOME/.vim
	set rtp+=$H/.vim/vundle/
elseif is_win
	set rtp+=$HOME/.vim/vundle
endif

let g:bundle_dir = g:vim_home . '/bundle'

if ! isdirectory(g:bundle_dir)
	call mkdir(g:bundle_dir)
endif

call vundle#rc(g:bundle_dir)

Bundle 'bcat/abbott.vim'
Bundle 'basyura/TweetVim'
Bundle 'basyura/bitly.vim'
Bundle 'basyura/twibill.vim'
Bundle 'fuenor/qfixhowm'
Bundle 'fuenor/vim-make-syntax'
Bundle 'fuenor/JpFormat.vim'
Bundle 'h1mesuke/unite-outline'
Bundle 'jelera/vim-javascript-syntax'
Bundle 'jelera/vim-gummybears-colorscheme'
Bundle 'gregsexton/VimCalc'
Bundle 'houtsnip/vim-emacscommandline'
Bundle 'godlygeek/csapprox'
Bundle 'jnurmine/Zenburn'
Bundle 'delphinus35/vim-pastefire'
"Bundle 'koron/chalice'
Bundle 'delphinus35/chalice'
Bundle 'Lokaltog/vim-easymotion'
"Bundle 'Lokaltog/vim-powerline'
Bundle 'delphinus35/vim-powerline'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'mattn/gist-vim'
"Bundle 'mattn/webapi-vim'
Bundle 'basyura/webapi-vim'
Bundle 'pix/vim-align'
Bundle 'rainux/vim-desert-warm-256'
Bundle 'rkitover/vimpager'
Bundle 'Shougo/unite.vim'
Bundle 'Shougo/vimfiler'
Bundle 'Shougo/vimproc'
Bundle 'Shougo/vimshell'
Bundle 'Shougo/neocomplcache'
Bundle 'thinca/vim-quickrun'
Bundle 'thinca/vim-ref'
Bundle 'thinca/vim-visualstar'
Bundle 'tpope/vim-fugitive'
Bundle 'tyru/current-func-info.vim'
Bundle 'tyru/open-browser.vim'
Bundle 'ujihisa/unite-colorscheme'
Bundle 'vim-jp/vimdoc-ja'
Bundle 'vim-scripts/calendar.vim--Matsumoto'
Bundle 'vim-scripts/Color-Sampler-Pack'
Bundle 'vim-scripts/compilerjsl.vim'
Bundle 'vim-scripts/DrawIt'
Bundle 'vim-scripts/errormarker.vim'
Bundle 'vim-scripts/Gundo'
Bundle 'vim-scripts/Perl-MooseX.Declare-Syntax'
Bundle 'vim-scripts/vcscommand.vim'
Bundle 'ynkdir/vim-funlib'

Bundle 'vba-hicolors'
Bundle 'vba-indguide'

"Bundle 'surround.vim'
"Bundle 'neon-PK'

filetype plugin indent on

if is_remora || is_office_win || is_office_cygwin
	set rtp+=~/.vim/
elseif is_office
	set rtp^=$H/.vim/
endif

syntax on
