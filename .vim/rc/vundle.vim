" シェルの位置を元に戻す
if is_office
	set shell=/bin/sh
elseif is_office_win
	set shell=$SYSTEMROOT\system32\cmd.exe
endif

" Vundle 設定開始
set nocompatible
filetype off

" Vundle へのパス
if is_remora || is_office_cygwin || is_backup
	set rtp+=~/.vim/vundle
elseif is_office 
	set rtp-=$HOME/.vim
	set rtp+=$H/.vim/vundle/
elseif is_win
	set rtp+=$HOME/.vim/vundle
endif

" プラグイン保存パス
let g:bundle_dir = g:vim_home . '/bundle'

" ディレクトリが存在しなければ作成
if ! isdirectory(g:bundle_dir)
	call mkdir(g:bundle_dir)
endif

call vundle#rc(g:bundle_dir)

Bundle 'bcat/abbott.vim'
Bundle 'basyura/TweetVim'
Bundle 'basyura/bitly.vim'
Bundle 'basyura/twibill.vim'
Bundle 'dannyob/quickfixstatus'
Bundle 'delphinus35/vim-pastefire'
Bundle 'fuenor/qfixhowm'
Bundle 'fuenor/vim-make-syntax'
Bundle 'fuenor/JpFormat.vim'
Bundle 'godlygeek/csapprox'
Bundle 'gregsexton/VimCalc'
Bundle 'houtsnip/vim-emacscommandline'
Bundle 'h1mesuke/unite-outline'
"Bundle 'jceb/vim-hier'
Bundle 'jelera/vim-javascript-syntax'
Bundle 'jelera/vim-gummybears-colorscheme'
Bundle 'jnurmine/Zenburn'
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
Bundle 'rkitover/perl-vim-mxd'
Bundle 'rkitover/vimpager'
Bundle 'scrooloose/nerdtree'
"Bundle 'scrooloose/syntastic'
Bundle 'delphinus35/syntastic'
Bundle 'Shougo/unite.vim'
Bundle 'Shougo/vimfiler'
Bundle 'Shougo/vimproc'
Bundle 'Shougo/vimshell'
Bundle 'Shougo/neocomplcache'
Bundle 'Shougo/neocomplcache-snippets-complete'
Bundle 'sjl/badwolf'
"Bundle 'sjl/clam.vim'
Bundle 'delphinus35/clam.vim'
Bundle 'thinca/vim-quickrun'
Bundle 'thinca/vim-ref'
Bundle 'thinca/vim-visualstar'
Bundle 'tpope/vim-fugitive'
Bundle 'tyru/current-func-info.vim'
Bundle 'tyru/open-browser.vim'
Bundle 'ujihisa/unite-colorscheme'
Bundle 'vim-jp/vimdoc-ja'
Bundle 'vim-scripts/Color-Sampler-Pack'
"Bundle 'vim-scripts/cmdline-completion'
Bundle 'delphinus35/cmdline-completion'
Bundle 'vim-scripts/compilerjsl.vim'
Bundle 'vim-scripts/DrawIt'
"Bundle 'vim-scripts/errormarker.vim'
Bundle 'vim-scripts/Gundo'
Bundle 'vim-scripts/sudo.vim'
Bundle 'vim-scripts/vcscommand.vim'
Bundle 'ynkdir/vim-funlib'

Bundle 'vba-hicolors'
Bundle 'vba-indguide'
Bundle 'vba-csv'

Bundle 'zip-yankring'

"Bundle 'surround.vim'
"Bundle 'neon-PK'

filetype plugin indent on

if is_remora || is_office_win || is_office_cygwin
	set rtp+=~/.vim/
elseif is_office
	set rtp^=$H/.vim/
endif

syntax on
