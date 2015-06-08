"===============================================================================
" NeoBundle 設定開始
"===============================================================================

" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

" プラグイン保存パス
let g:bundle_dir    = g:home       . '/.vim/bundle'
let g:neobundle_dir = g:bundle_dir . '/neobundle.vim'
let g:after_dir     = g:home       . '/.vim/after'

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

" Set vimproc
NeoBundle 'Shougo/vimproc.vim', {'build': {
      \   'cygwin': 'make -f make_cygwin.mak',
      \   'mac':    'make -f make_mac.mak',
      \   'unix':   'make -f make_unix.mak',
      \ }}

" プラグイン {{{
NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'ap/vim-css-color'
NeoBundle 'chikatoike/concealedyank.vim'
NeoBundle 'delphinus35/vim-colors-solarized'
NeoBundle 'delphinus35/vim-emacscommandline'
NeoBundle 'delphinus35/vim-unimpaired'
NeoBundle 'fuenor/JpFormat.vim'
NeoBundle 'joker1007/vim-markdown-quote-syntax'
NeoBundle 'kana/vim-vspec'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'motemen/xslate-vim'
NeoBundle 'moznion/vim-cpanfile'
NeoBundle 'myusuf3/numbers.vim'
NeoBundle 'othree/html5.vim'
NeoBundle 'ryanoasis/vim-webdevicons'
NeoBundle 'tpope/vim-fugitive', {'augroup': 'fugitive'}
NeoBundle 'tpope/vim-rails'
NeoBundle 'vim-scripts/HiColors'
NeoBundle 'vim-scripts/Sunset'
NeoBundle 'vim-scripts/applescript.vim'
NeoBundle 'vim-scripts/nginx.vim'

NeoBundle 'osyo-manga/vim-watchdogs', {'depends': [
      \   'Shougo/vimproc.vim',
      \   'dannyob/quickfixstatus',
      \   'cohama/vim-hier',
      \   'osyo-manga/shabadou.vim',
      \   'thinca/vim-quickrun',
      \ ]}

NeoBundle 'vim-scripts/LineJuggler', {'depends': [
      \   'vim-scripts/ingo-library',
      \   'tpope/vim-repeat',
      \   'vim-scripts/visualrepeat',
      \ ]}
" }}}

" プラグイン（遅延ロード） {{{
NeoBundleLazy 'Shougo/vimfiler', {
      \ 'depends': ['Shougo/vimproc.vim'],
      \ 'commands': [
      \   {'name': 'VimFiler', 'complete': 'customlist,vimfiler#complete'},
      \   'VimFilerExplorer', 'Edit', 'Read', 'Source', 'Write',
      \ ],
      \ 'on_source': 'unite.vim',
      \ 'explorer': 1,
      \ }
NeoBundleLazy 'Shougo/vimshell', {
      \ 'depends': ['Shougo/vimproc.vim'],
      \ 'commands': [
      \   {'name': 'VimShell', 'complete': 'customlist,vimshell#complete'},
      \   'VimShellExecute', 'VimShellInteractive', 'VimShellTerminal', 'VimShellPop',
      \ ]}

NeoBundleLazy 'Shougo/unite.vim'

NeoBundleLazy 'Kocha/vim-unite-tig',       {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'Shougo/neomru.vim',         {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'Shougo/unite-outline',      {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'basyura/unite-rails',       {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'delphinus35/unite-ghq',     {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'kannokanno/unite-dwm',      {'depends': ['Shougo/unite.vim', 'spolu/dwm.vim'], 'on_source': ['unite.vim']}
NeoBundleLazy 'pasela/unite-webcolorname', {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'tsukkee/unite-tag',         {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'osyo-manga/unite-qfixhowm', {
      \ 'depends': [
      \   'Shougo/unite.vim',
      \   ['delphinus35/qfixhowm', {'mappings': ['g,c', 'g,m']}],
      \ ]}

NeoBundleLazy 'vim-jp/vital.vim'
NeoBundleLazy 'vim-jp/vimdoc-ja'

NeoBundleLazy 'tyru/open-browser-github.vim', {'depends': ['tyru/open-browser.vim']}

NeoBundleLazy 'Shougo/vinarise.vim',     {'commands': ['Vinarise']}
NeoBundleLazy 'airblade/vim-rooter',     {'commands': ['Rooter']}
NeoBundleLazy 'delphinus35/lcpeek.vim',  {'commands': ['PeekInput']}
NeoBundleLazy 'gregsexton/VimCalc',      {'commands': ['Calc']}
NeoBundleLazy 'kannokanno/previm',       {'commands': ['PreVimOpen']}
NeoBundleLazy 'sjl/gundo.vim',           {'commands': ['GundoToggle']}
NeoBundleLazy 'thinca/vim-prettyprint',  {'commands': ['PP', 'PrettyPrint']}
NeoBundleLazy 'tyru/capture.vim',        {'commands': ['Capture']}
NeoBundleLazy 'vim-scripts/AnsiEsc.vim', {'commands': ['AnsiEsc']}

NeoBundleLazy 'ChrisYip/Better-CSS-Syntax-for-Vim',            {'filetypes': ['css']}
NeoBundleLazy 'c9s/perlomni.vim',                              {'filetypes': ['perl']}
NeoBundleLazy 'catalinciurea/perl-nextmethod',                 {'filetypes': ['perl']}
NeoBundleLazy 'csv.vim',                                       {'filetypes': ['csv']}
NeoBundleLazy 'delphinus35/perl-test-base.vim',                {'filetypes': ['perl']}
NeoBundleLazy 'delphinus35/plantuml-syntax', 'fix-for-isnot#', {'filetypes': ['markdown', 'plantuml']}
NeoBundleLazy 'dsawardekar/wordpress.vim',                     {'filetypes': ['php']}
NeoBundleLazy 'jelera/vim-javascript-syntax',                  {'filetypes': ['javascript']}
NeoBundleLazy 'rhysd/vim-textobj-ruby',                        {'filetypes': ['ruby'], 'depends': ['kana/vim-textobj-user']}
NeoBundleLazy 'supermomonga/neocomplete-rsense.vim',           {'filetypes': ['ruby'], 'insert': 1}
NeoBundleLazy 'vim-perl/vim-perl',                             {'filetypes': ['perl']}

NeoBundleLazy 'LeafCage/yankround.vim',       {'mappings': ['<Plug>(yankround-']}
NeoBundleLazy 'Lokaltog/vim-easymotion',      {'mappings': ['<Plug>(easymotion-']}
NeoBundleLazy 'delphinus35/open-github-link', {'mappings': ['<Plug>(open-github-link']}
NeoBundleLazy 'junegunn/vim-easy-align',      {'mappings': ['<Plug>(EasyAlign)', '<Plug>(LiveEasyAlign)']}
NeoBundleLazy 'spolu/dwm.vim',                {'mappings': ['<Plug>DWM']}
NeoBundleLazy 'tpope/vim-capslock',           {'mappings': ['i', '<Plug>CapsLockToggle']}
NeoBundleLazy 't9md/vim-quickhl',             {'mappings': ['<Plug>(quickhl-', '<Plug>(operator-quickhl-']}
NeoBundleLazy 't9md/vim-choosewin',           {'mappings': ['<Plug>(choosewin)']}
NeoBundleLazy 'thinca/vim-fontzoom',          {'mappings': ['<Plug>(fontzoom-'], 'commands': ['Fontzoom'], 'gui': 1}

NeoBundleLazy 'tpope/vim-endwise', {
      \ 'filetypes': [
      \   'lua', 'elixir', 'ruby', 'crystal', 'sh', 'zsh', 'vb', 'vbnet',
      \   'aspvbs', 'vim', 'c', 'cpp', 'xdefaults', 'objc', 'matlab',
      \ ]}
NeoBundleLazy 'thinca/vim-ref', {
      \ 'depends':       ['Shougo/unite.vim'],
      \ 'commands':      ['Ref'],
      \ 'unite_sources': 'ref',
      \ }
NeoBundleLazy 'lambdalisue/vim-gista', {
      \ 'depends':       ['Shougo/unite.vim', 'tyru/open-browser.vim'],
      \ 'commands':      ['Gista'],
      \ 'mappings':      '<Plug>(gista-',
      \ 'unite_sources': 'gista',
      \ }
NeoBundleLazy 'basyura/TweetVim', {
      \ 'depends':  ['basyura/bitly.vim', 'basyura/twibill.vim'],
      \ 'commands': 'TweetVimHomeTimeLine',
      \ }
" }}}

" Mac 専用
if has('macunix')
  NeoBundle 'msanders/cocoa.vim'
  NeoBundleLazy 'troydm/pb.vim',     {'commands': ['Pbyank', 'Pbpaste', 'PbPaste']}
  NeoBundleLazy 'rizzatti/dash.vim', {'commands': ['Dash'], 'gui': 1}
else
  NeoBundleLazy 'rkitover/vimpager'
endif

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
