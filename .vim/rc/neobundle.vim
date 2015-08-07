scriptencoding utf-8

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

" Required:
call neobundle#begin(expand(g:bundle_dir))

let g:neobundle#default_options._ = {'verbose': 1}

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

let s:bundled_vimproc_directory = expand('$VIM/plugins/vimproc')
if ! (has('macunix') && has('kaoriya') && isdirectory(s:bundled_vimproc_directory))
  NeoBundle 'Shougo/vimproc.vim', {'build': {
        \   'cygwin': 'make -f make_cygwin.mak',
        \   'mac':    'make -f make_mac.mak',
        \   'unix':   'make -f make_unix.mak',
        \ }}
endif

" プラグイン {{{
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'delphinus35/vim-colors-solarized'
NeoBundle 'delphinus35/vim-emacscommandline'
NeoBundle 'delphinus35/vim-unimpaired'
NeoBundle 'joker1007/vim-markdown-quote-syntax'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'motemen/xslate-vim'
NeoBundle 'moznion/vim-cpanfile'
NeoBundle 'myusuf3/numbers.vim'
NeoBundle 'othree/html5.vim'
NeoBundle 'ryanoasis/vim-devicons'
NeoBundle 'thinca/vim-visualstar'
NeoBundle 'tpope/vim-fugitive', {'augroup': 'fugitive'}
NeoBundle 'vim-scripts/HiColors'
NeoBundle 'vim-scripts/Sunset'
NeoBundle 'vim-scripts/applescript.vim'
NeoBundle 'vim-scripts/nginx.vim'

NeoBundle 'osyo-manga/vim-watchdogs', {'depends': [
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
      \ 'commands': [
      \   {'name': 'VimFiler', 'complete': 'customlist,vimfiler#complete'},
      \   'VimFilerExplorer', 'Edit', 'Read', 'Source', 'Write',
      \ ],
      \ 'on_source': 'unite.vim',
      \ 'explorer': 1,
      \ }
NeoBundleLazy 'Shougo/vimshell', {
      \ 'commands': [
      \   {'name': 'VimShell', 'complete': 'customlist,vimshell#complete'},
      \   'VimShellExecute', 'VimShellInteractive', 'VimShellTerminal', 'VimShellPop',
      \ ]}

NeoBundleLazy 'Kocha/vim-unite-tig',       {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'Shougo/neomru.vim',         {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'Shougo/unite-outline',      {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'basyura/unite-rails',       {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'delphinus35/unite-ghq',     {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'pasela/unite-webcolorname', {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'sorah/unite-bundler',       {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'tsukkee/unite-tag',         {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'osyo-manga/unite-qfixhowm', {'depends': ['Shougo/unite.vim', 'fuenor/qfixhowm']}

" enable on source unite.vim for `dwm_new` action
NeoBundleLazy 'kannokanno/unite-dwm', {
      \ 'depends':   ['Shougo/unite.vim', 'spolu/dwm.vim'],
      \ 'on_source': ['unite.vim'],
      \ }

NeoBundleLazy 'fuenor/qfixhowm'

if neobundle#tap('qfixhowm')
  call neobundle#config({
        \ 'autoload': {
        \   'mappings': ['g,m', 'g,c', 'g,s', 'g,q'],
        \ }})
  call neobundle#untap()
endif

if neobundle#tap('unite-qfixhowm')
  call neobundle#config({
        \ 'autoload': {
        \   'on_source': ['qfixhowm'],
        \ }})
  call neobundle#untap()
endif

NeoBundleLazy 'vim-jp/vital.vim'
NeoBundleLazy 'vim-jp/vimdoc-ja'

NeoBundleLazy 'dhruvasagar/vim-table-mode',   {'function_prefix': 'tablemode'}
NeoBundleLazy 'tyru/open-browser-github.vim', {'depends': ['tyru/open-browser.vim']}

NeoBundleLazy 'Shougo/vinarise.vim',     {'commands': ['Vinarise']}
NeoBundleLazy 'airblade/vim-rooter',     {'commands': ['Rooter']}
NeoBundleLazy 'delphinus35/lcpeek.vim',  {'commands': ['PeekInput']}
NeoBundleLazy 'fuenor/JpFormat.vim',     {'commands': ['JpFormatAll', 'JpJoinAll'], 'filetypes': ['howm_memo']}
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
NeoBundleLazy 'kana/vim-vspec',                                {'filetypes': ['vim']}
NeoBundleLazy 'rhysd/vim-textobj-ruby',                        {'filetypes': ['ruby'], 'depends': ['kana/vim-textobj-user']}
NeoBundleLazy 'tpope/vim-rails',                               {'filetypes': ['ruby']}
NeoBundleLazy 'vim-perl/vim-perl',                             {'filetypes': ['perl']}

NeoBundleLazy 'LeafCage/yankround.vim',       {'mappings': ['<Plug>(yankround-']}
NeoBundleLazy 'Lokaltog/vim-easymotion',      {'mappings': ['<Plug>(easymotion-']}
NeoBundleLazy 'chikatoike/concealedyank.vim', {'mappings': ['<Plug>(operator-concealedyank)']}
NeoBundleLazy 'delphinus35/open-github-link', {'mappings': ['<Plug>(open-github-link']}
NeoBundleLazy 'junegunn/vim-easy-align',      {'mappings': ['<Plug>(EasyAlign)', '<Plug>(LiveEasyAlign)']}
NeoBundleLazy 'spolu/dwm.vim',                {'mappings': ['<Plug>DWM']}
NeoBundleLazy 'tpope/vim-capslock',           {'mappings': ['i', '<Plug>CapsLockToggle']}
NeoBundleLazy 't9md/vim-quickhl',             {'mappings': ['<Plug>(quickhl-', '<Plug>(operator-quickhl-']}
NeoBundleLazy 't9md/vim-choosewin',           {'mappings': ['<Plug>(choosewin)']}
NeoBundleLazy 'thinca/vim-fontzoom',          {'mappings': ['<Plug>(fontzoom-'], 'commands': ['Fontzoom'], 'gui': 1}

NeoBundleLazy 'Shougo/neocomplete.vim', {'insert': 1}
NeoBundleLazy 'supermomonga/neocomplete-rsense.vim', {
      \ 'depends':   ['Shougo/neocomplete.vim'],
      \ 'filetypes': ['ruby'],
      \ 'insert':    1,
      \ }
NeoBundleLazy 'delphinus35/neocomplete-json-schema', {
      \ 'depends':   ['Shougo/neocomplete.vim'],
      \ 'filetypes': ['json'],
      \ 'insert':    1,
      \ }
NeoBundleLazy 'ap/vim-css-color', {'filetypes': [
      \ 'css', 'html', 'less', 'lua', 'moon', 'sass', 'scss', 'stylus', 'vim',
      \ ]}
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
" }}}

" Mac 専用
if has('macunix')
  NeoBundleLazy 'msanders/cocoa.vim', {'filetypes': ['objc']}
  NeoBundleLazy 'troydm/pb.vim',      {'commands': ['Pbyank', 'Pbpaste', 'PbPaste']}
  NeoBundleLazy 'rizzatti/dash.vim',  {'commands': ['Dash'], 'gui': 1}
else
  NeoBundleLazy 'rkitover/vimpager'
endif

if ! has('macvim')
  NeoBundle 'elzr/vim-json'
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
