scriptencoding utf-8

" Encodings {{{
set fileencoding=utf-8
if !has('gui_running') && &encoding !=# 'cp932' && &term ==# 'win32'
  set termencoding=cp932
else
  set termencoding=utf-8
endif
if !has('gui_macvim')
  set fileencodings=ucs-bom,utf-8,eucjp,cp932,ucs-2le,latin1,iso-2022-jp
endif
" }}}

" Tabs {{{
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
" }}}

" Directories {{{
set undofile
set directory=/tmp
set backupdir=/tmp
set undodir=/tmp
" needed for editing crontab in macOS
set backupskip^=/private/tmp/*

if &shell !=# 'zsh' && executable('/usr/local/bin/zsh')
  set shell=/usr/local/bin/zsh
endif
" Add -f (--no-rcs) option to use current PATH & GOPATH
set shellcmdflag=-f\ -c
" }}}

" Searching {{{
set ignorecase
set smartcase
if exists('+inccommand')
  set inccommand=split
endif
" }}}

" Display {{{
set ambiwidth=single
set noshowmode
set showmatch
set relativenumber
set number
set numberwidth=3
set list
set listchars=tab:░\ ,trail:␣,eol:⤶,extends:→,precedes:←,nbsp:¯
set showtabline=1
set colorcolumn=80,140
set cmdheight=2
set noruler
" }}}

" Indents and arranging formats {{{
set smartindent
set formatoptions+=nmMj
" Detect sequence numbers with parentheses
set formatlistpat=^\\s*\\%(\\d\\+\\\|[-a-z]\\)\\%(\\\ -\\\|[]:.)}\\t]\\)\\?\\s\\+
set wrap
set breakindent
set showbreak=→\  
set nofixendofline
" }}}

" Mouse {{{
set mouse=a
" }}}

" Colorschemes {{{
set termguicolors
syntax enable

" Use Solarized Light when iTerm2 reports 11;15 for $COLORFGBG
let g:bg_light = $COLORFGBG ==# '11;15'
if g:bg_light
  set background=light
endif
let g:use_solarized = g:bg_light || $SOLARIZED
if g:use_solarized
  colorscheme solarized8
else
  colorscheme nord
endif
" }}}

" Title {{{
if exists('$TMUX')
  set t_ts=k
  set t_fs=\
endif

set title
" }}}

" その他 {{{
set scrolloff=3
set sidescrolloff=5
set fileformat=unix
set fileformats=unix,dos
set grepprg=pt\ --nogroup\ --nocolor
set diffopt=internal,filler,vertical,iwhite,algorithm:patience
set synmaxcol=0
set virtualedit=block
set wildmode=full
set helplang=ja
set lazyredraw
set matchpairs+=（:）,「:」,【:】,［:］,｛:｝,＜:＞
set completeopt+=menuone
set completeopt-=preview
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
      \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
      \,sm:block-blinkwait175-blinkoff150-blinkon175
" }}}

" Neovim specific settings {{{
if has('nvim')
  set fillchars=diff:░,eob:‣
  set pumblend=30  " transparency
  set shada=!,'1000,<50,s10,h  " Store 1000 entries on oldfiles
else
  set autoindent
  set backspace=indent,eol,start
  set clipboard=autoselectml
  set fillchars=diff:░,vert:│
  set history=10000
  set hlsearch
  set incsearch
  set laststatus=2
  set nrformats=bin,hex
  set pyxversion=3
  set shortmess+=c  " for echodoc
  set showcmd
  set sidescroll=1
  set smarttab
  set ttyfast
  set ttymouse=sgr
  set viminfo='1000,<50,s10,h
  set wildmenu
endif
" }}}

" vim:se fdm=marker:
