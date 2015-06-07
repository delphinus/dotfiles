" シェルの位置を元に戻す
if is_win
  set shell=$SYSTEMROOT\system32\cmd.exe
endif

"===============================================================================
" NeoBundle 設定開始
"===============================================================================

" プラグイン保存パス
let g:bundle_dir    = g:home       . '/.vim/bundle'
let g:neobundle_dir = g:bundle_dir . '/neobundle.vim'
let g:after_dir     = g:home       . '/.vim/after'
let g:mybundle_dir  = g:home       . '/.vim/mybundle'

" NeoBundle へのパス
if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif
  execute 'set runtimepath-=' . g:home . '/.vim/'
  execute 'set runtimepath+=' . g:neobundle_dir . '/,' . g:after_dir . '/'
endif

" デフォルトプロトコル
let g:neobundle#types#git#default_protocol='https'

" Required:
call neobundle#begin(expand(g:bundle_dir))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Use neobundle standard recipes.
NeoBundle 'Shougo/neobundle-vim-recipes'

" Set vimproc
NeoBundle 'Shougo/vimproc.vim', {'build': {
    \   'cygwin': 'make -f make_cygwin.mak',
    \   'mac': 'make -f make_mac.mak',
    \   'unix': 'make -f make_unix.mak',
    \   },
    \ }



" プラグイン（github） {{{

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
NeoBundle 'Shougo/vinarise.vim'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'airblade/vim-rooter'
"NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'delphinus35/vim-colors-solarized'
NeoBundle 'ap/vim-css-color'
"NeoBundle 'amdt/sunset'
NeoBundle 'vim-scripts/Sunset'
"NeoBundle 'aklt/plantuml-syntax'
NeoBundle 'delphinus35/plantuml-syntax', 'fix-for-isnot#'
NeoBundle 'chikatoike/concealedyank.vim'
NeoBundle 'delphinus35/open-github-link'
NeoBundle 'dsawardekar/wordpress.vim'
NeoBundle 'fuenor/JpFormat.vim'
"NeoBundle 'houtsnip/vim-emacscommandline'
NeoBundle 'delphinus35/vim-emacscommandline'
"NeoBundle 'jaxbot/github-issues.vim'
NeoBundle 'joker1007/vim-markdown-quote-syntax'
NeoBundle 'junegunn/vim-easy-align'
NeoBundle 'kana/vim-vspec'
NeoBundle 'kannokanno/previm'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'koron/cmigemo'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'mattn/webapi-vim'
NeoBundle 'motemen/xslate-vim'
NeoBundle 'moznion/vim-cpanfile'
NeoBundle 'myusuf3/numbers.vim'
NeoBundle 'nishigori/increment-activator'
NeoBundle 'othree/html5.vim'
NeoBundle 'reedes/vim-colors-pencil'
NeoBundle 'rhysd/neco-ruby-keyword-args', {'depends': ['Shougo/neocomplete']}
NeoBundle 'rhysd/vim-textobj-ruby',       {'depends': ['kana/vim-textobj-user']}
NeoBundle 'ryanoasis/vim-webdevicons'
NeoBundle 't9md/vim-quickhl'
NeoBundle 't9md/vim-choosewin'
NeoBundle 'thinca/vim-fontzoom'
NeoBundle 'thinca/vim-prettyprint'
NeoBundle 'thinca/vim-ref'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-rails'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-repeat'
"NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'delphinus35/vim-unimpaired'
NeoBundle 'tyru/open-browser-github.vim', {'depends': ['tyru/open-browser.vim']}
NeoBundle 'vim-jp/vimdoc-ja'
NeoBundle 'vim-jp/vital.vim'
NeoBundle 'vim-scripts/AnsiEsc.vim'
NeoBundle 'vim-scripts/HiColors'
NeoBundle 'vim-scripts/LineJuggler', {'depends': ['vim-scripts/ingo-library']}
NeoBundle 'vim-scripts/applescript.vim'
NeoBundle 'vim-scripts/nginx.vim'
NeoBundle 'vim-scripts/visualrepeat'

" }}}

NeoBundleLazy 'Shougo/unite.vim'

NeoBundleLazy 'Kocha/vim-unite-tig',       {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'Shougo/neomru.vim',         {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'Shougo/unite-outline',      {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'basyura/unite-rails',       {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'delphinus35/unite-ghq',     {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'kannokanno/unite-dwm',      {'depends': ['Shougo/unite.vim', 'spolu/dwm.vim']}
NeoBundleLazy 'pasela/unite-webcolorname', {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'tsukkee/unite-tag',         {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'Shougo/vimfiler',           {'depends': ['Shougo/vimproc.vim'], 'on_source': 'unite.vim'}
NeoBundleLazy 'Shougo/vimshell',           {'depends': ['Shougo/vimproc.vim']}

NeoBundleLazy 'gregsexton/VimCalc',     {'autoload': {'commands':  ['Calc']}}
NeoBundleLazy 'tyru/capture.vim',       {'autoload': {'commands':  ['Capture']}}
NeoBundleLazy 'sjl/gundo.vim',          {'autoload': {'commands':  ['GundoToggle']}}
NeoBundleLazy 'delphinus35/lcpeek.vim', {'autoload': {'commands':  ['PeekInput']}}
NeoBundleLazy 'ChrisYip/Better-CSS-Syntax-for-Vim', {'autoload': {'filetypes': ['css']}}
NeoBundleLazy 'csv.vim',                            {'autoload': {'filetypes': ['csv']}}
NeoBundleLazy 'jelera/vim-javascript-syntax',       {'autoload': {'filetypes': ['javascript']}}
NeoBundleLazy 'c9s/perlomni.vim',                   {'autoload': {'filetypes': ['perl']}}
NeoBundleLazy 'catalinciurea/perl-nextmethod',      {'autoload': {'filetypes': ['perl']}}
NeoBundleLazy 'delphinus35/perl-test-base.vim',     {'autoload': {'filetypes': ['perl']}}
NeoBundleLazy 'vim-perl/vim-perl',                  {'autoload': {'filetypes': ['perl']}}
NeoBundleLazy 'tpope/vim-capslock', {'autoload': {'mappings': ['i', '<Plug>CapsLockToggle']}}
NeoBundleLazy 'lambdalisue/vim-gista', {
      \ 'depends': ['Shougo/unite.vim', 'tyru/open-browser.vim'],
      \ 'autoload': {
      \   'commands': ['Gista'],
      \   'mappings': '<Plug>(gista-',
      \   'unite_sources': 'gista',
      \ }}
NeoBundleLazy 'delphinus35/qfixhowm', {
      \ 'autoload': {'mappings': 'g,c'}}
NeoBundleLazy 'osyo-manga/unite-qfixhowm', {
      \ 'depends': ['delphinus35/qfixhowm', 'Shougo/unite.vim']}

" TweetVim
NeoBundleLazy 'basyura/TweetVim', {'depends': [
    \   'basyura/bitly.vim',
    \   'basyura/twibill.vim',
    \ ],
    \ 'autoload': {'commands': 'TweetVimHomeTimeLine'}}

" Mac 専用
if has('macunix')
  NeoBundle 'msanders/cocoa.vim'
  NeoBundle 'troydm/pb.vim'
  NeoBundle 'rizzatti/dash.vim'

else
  NeoBundle 'rkitover/vimpager'
endif

" Powerline がうまく動かないとき用
if filereadable(g:home . '/.no-powerline')
  NeoBundle 'bling/vim-airline'
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
  execute 'set runtimepath+=' . g:home
endif

call neobundle#end()

" Required:
filetype plugin indent on

" インストールチェック
NeoBundleCheck

if !has('vim_starting')
  " Call on_source hook when reloading .vimrc.
  call neobundle#call_hook('on_source')
endif

" vim:se et fdm=marker:
