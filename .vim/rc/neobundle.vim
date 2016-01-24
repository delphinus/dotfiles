scriptencoding utf-8

"===============================================================================
" NeoBundle 設定開始
"===============================================================================

" Note: Skip initialization for vim-tiny or vim-small.
if 0 | endif

" プラグイン保存パス
let g:bundle_dir    = g:home       . '/.vim/bundle'
let g:neobundle_dir = g:bundle_dir . '/neobundle.vim'
let g:after_dir     = g:home       . '/.vim/after'

" NeoBundle へのパス
if has('vim_starting')
  if &compatible
    " vint: -ProhibitSetNoCompatible
    set nocompatible               " Be iMproved
    " vint: +ProhibitSetNoCompatible
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

let s:is_vimproc_bundled = isdirectory(expand('$VIM/plugins/vimproc'))
if ! (has('macunix') && has('kaoriya') && s:is_vimproc_bundled)
  NeoBundle 'Shougo/vimproc.vim', {'build': {
        \   'cygwin': 'make -f make_cygwin.mak',
        \   'mac':    'make -f make_mac.mak',
        \   'unix':   'make -f make_unix.mak',
        \ }}
endif

" プラグイン {{{
NeoBundle 'Glench/Vim-Jinja2-Syntax'
NeoBundle 'atelierbram/vim-colors_atelier-schemes'
NeoBundle 'cespare/vim-toml'
NeoBundle 'delphinus35/vim-colors-solarized', 'for-hydrozen-fork'
NeoBundle 'delphinus35/vim-emacscommandline'
NeoBundle 'delphinus35/vim-markdown', 'merged-inline_and_code_fixes'
NeoBundle 'delphinus35/vim-unimpaired'
NeoBundle 'digitaltoad/vim-jade'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'leafgarland/typescript-vim'
NeoBundle 'motemen/xslate-vim'
NeoBundle 'moznion/vim-cpanfile'
NeoBundle 'othree/html5.vim'
NeoBundle 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
"NeoBundle 'ryanoasis/vim-devicons'
NeoBundle 'delphinus35/vim-devicons', 'detect-darwin-with-lighter-method'
NeoBundle 'thinca/vim-visualstar'
NeoBundle 'tpope/vim-fugitive', {'augroup': 'fugitive'}
"NeoBundle 'tpope/vim-rails'
NeoBundle 'delphinus35/vim-rails', 'feature/recognize-ridgepole'
NeoBundle 'vim-jp/vital.vim'
NeoBundle 'vim-scripts/HiColors'
NeoBundle 'vim-scripts/applescript.vim'
NeoBundle 'vim-scripts/nginx.vim'
NeoBundle 'https://raw.githubusercontent.com/tmux/tmux/master/examples/tmux.vim', {
      \ 'type':        'raw',
      \ 'script_type': 'syntax',
      \ }

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
      \ 'on_cmd': [
      \   {'name': 'VimFiler', 'complete': 'customlist,vimfiler#complete'},
      \   'VimFilerExplorer', 'Edit', 'Read', 'Source', 'Write',
      \ ],
      \ 'on_source': 'unite.vim',
      \ 'on_path':   '.*',
      \ }
NeoBundleLazy 'Shougo/vimshell', {
      \ 'on_cmd': [
      \   {'name': 'VimShell', 'complete': 'customlist,vimshell#complete'},
      \   'VimShellExecute', 'VimShellInteractive', 'VimShellTerminal', 'VimShellPop',
      \ ]}
NeoBundleLazy 'Shougo/tabpagebuffer.vim',  {
      \ 'on_source': ['unite.vim', 'vimfiler', 'vimshell'],
      \ }

NeoBundleLazy 'Kocha/vim-unite-tig',       {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'Shougo/neomru.vim',         {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'Shougo/unite-outline',      {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'basyura/unite-rails',       {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'delphinus35/unite-ghq',     {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'pekepeke/vim-unite-z',      {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'sorah/unite-bundler',       {'depends': ['Shougo/unite.vim']}
NeoBundleLazy 'tsukkee/unite-tag',         {'depends': ['Shougo/unite.vim', 'Shougo/neoinclude.vim']}
NeoBundleLazy 'osyo-manga/unite-qfixhowm', {'depends': ['Shougo/unite.vim', 'fuenor/qfixhowm']}

" enable on source unite.vim for `dwm_new` action
NeoBundleLazy 'kannokanno/unite-dwm', {
      \ 'depends':   ['Shougo/unite.vim', 'spolu/dwm.vim'],
      \ 'on_source': ['unite.vim'],
      \ }

NeoBundleLazy 'fuenor/qfixhowm'

if g:neobundle#tap('qfixhowm')
  call neobundle#config({
        \ 'on_map': ['g,m', 'g,c', 'g,s', 'g,q'],
        \ })
  call neobundle#untap()
endif

if g:neobundle#tap('unite-qfixhowm')
  call neobundle#config({
        \ 'on_source': ['qfixhowm'],
        \ })
  call neobundle#untap()
endif

NeoBundleLazy 'vim-jp/vimdoc-ja'

NeoBundleLazy 'dhruvasagar/vim-table-mode',   {'on_func': 'tablemode'}

NeoBundleLazy 'Shougo/vinarise.vim',     {'on_cmd': ['Vinarise']}
NeoBundleLazy 'airblade/vim-rooter',     {'on_cmd': ['Rooter']}
NeoBundleLazy 'fuenor/JpFormat.vim',     {'on_cmd': ['JpFormatAll', 'JpJoinAll'], 'on_ft': ['howm_memo']}
NeoBundleLazy 'gregsexton/VimCalc',      {'on_cmd': ['Calc']}
NeoBundleLazy 'kannokanno/previm',       {'on_cmd': ['PrevimOpen']}
NeoBundleLazy 'sjl/gundo.vim',           {'on_cmd': ['GundoToggle']}
NeoBundleLazy 'sgur/vim-lazygutter',     {'on_cmd': ['GitGutterToggle']}
NeoBundleLazy 'thinca/vim-prettyprint',  {'on_cmd': ['Capture', 'PP', 'PrettyPrint']}
NeoBundleLazy 'tyru/capture.vim',        {'on_cmd': ['Capture']}
NeoBundleLazy 'vim-scripts/AnsiEsc.vim', {'on_cmd': ['AnsiEsc']}

NeoBundleLazy 'ChrisYip/Better-CSS-Syntax-for-Vim', {'on_ft': ['css']}
NeoBundleLazy 'Quramy/tsuquyomi',                   {'on_ft': ['typescript']}
NeoBundleLazy 'c9s/perlomni.vim',                   {'on_ft': ['perl']}
NeoBundleLazy 'catalinciurea/perl-nextmethod',      {'on_ft': ['perl']}
NeoBundleLazy 'csv.vim',                            {'on_ft': ['csv']}
NeoBundleLazy 'delphinus35/perl-test-base.vim',     {'on_ft': ['perl']}
NeoBundleLazy 'aklt/plantuml-syntax',               {'on_ft': ['markdown', 'plantuml']}
NeoBundleLazy 'dsawardekar/wordpress.vim',          {'on_ft': ['php']}
NeoBundleLazy 'fatih/vim-go',                       {'on_ft': ['go']}
NeoBundleLazy 'jason0x43/vim-js-indent',            {'on_ft': ['javascript', 'typescript']}
NeoBundleLazy 'jelera/vim-javascript-syntax',       {'on_ft': ['javascript']}
NeoBundleLazy 'kana/vim-vspec',                     {'on_ft': ['vim']}
NeoBundleLazy 'rhysd/vim-textobj-ruby',             {'on_ft': ['ruby'], 'depends': ['kana/vim-textobj-user']}
NeoBundleLazy 'vim-perl/vim-perl',                  {'on_ft': ['perl']}

NeoBundleLazy 'chikatoike/concealedyank.vim', {'on_map': ['<Plug>(operator-concealedyank)']}
NeoBundleLazy 'delphinus35/vim-lycia',        {'on_map': ['<Plug>(lycia']}
NeoBundleLazy 'junegunn/vim-easy-align',      {'on_map': ['<Plug>(EasyAlign)', '<Plug>(LiveEasyAlign)']}
NeoBundleLazy 'spolu/dwm.vim',                {'on_map': ['<Plug>DWM']}
NeoBundleLazy 'tpope/vim-capslock',           {'on_map': [['i', '<Plug>CapsLockToggle']]}
NeoBundleLazy 't9md/vim-quickhl',             {'on_map': ['<Plug>(quickhl-', '<Plug>(operator-quickhl-']}
NeoBundleLazy 't9md/vim-choosewin',           {'on_map': ['<Plug>(choosewin)']}
NeoBundleLazy 'thinca/vim-fontzoom',          {'on_map': ['<Plug>(fontzoom-'], 'on_cmd': ['Fontzoom'], 'gui': 1}

NeoBundleLazy 'easymotion/vim-easymotion', {'on_map': ['<Plug>(easymotion-']}
NeoBundleLazy 'haya14busa/incsearch.vim', {
      \ 'depends': [
      \   'easymotion/vim-easymotion',
      \   'haya14busa/incsearch-easymotion.vim',
      \   'haya14busa/incsearch-fuzzy.vim',
      \ ],
      \ 'on_func': ['incsearch#'],
      \ }

NeoBundleLazy 'LeafCage/yankround.vim', {
      \ 'on_map':   ['<Plug>(yankround-'],
      \ 'on_unite': 'yankround',
      \ }

NeoBundleLazy 'tyru/open-browser.vim', {
      \ 'on_map': ['<Plug>(openbrowser-'],
      \ 'on_cmd': ['OpenBrowser', 'OpenBrowserSearch'],
      \ }

NeoBundleLazy 'Shougo/neocomplete.vim', {'on_i': 1}
NeoBundleLazy 'supermomonga/neocomplete-rsense.vim', {
      \ 'depends': ['Shougo/neocomplete.vim'],
      \ 'on_ft':   ['ruby'],
      \ 'on_i':    1,
      \ }
NeoBundleLazy 'delphinus35/neocomplete-json-schema', {
      \ 'depends': ['Shougo/neocomplete.vim'],
      \ 'on_ft':   ['json'],
      \ 'on_i':    1,
      \ }
NeoBundleLazy 'ap/vim-css-color', {'on_ft': [
      \   'css', 'html', 'less', 'lua', 'moon',
      \   'sass', 'scss', 'stylus', 'vim', 'plantuml',
      \ ]}
NeoBundleLazy 'tpope/vim-endwise', {
      \ 'on_ft': [
      \   'lua', 'elixir', 'ruby', 'crystal', 'sh', 'zsh', 'vb', 'vbnet',
      \   'aspvbs', 'vim', 'c', 'cpp', 'xdefaults', 'objc', 'matlab',
      \ ]}
NeoBundleLazy 'thinca/vim-ref', {
      \ 'depends':  ['Shougo/unite.vim'],
      \ 'on_cmd':   ['Ref'],
      \ 'on_unite': 'ref',
      \ }
NeoBundle 'lambdalisue/vim-gista'
NeoBundleLazy 'lambdalisue/vim-gista-unite', {
      \ 'depends': [
      \   'lambdalisue/vim-gista',
      \   'Shougo/unite.vim',
      \ ],
      \ 'on_unite': ['gista', 'gista/file'],
      \ }
NeoBundleLazy 'ujihisa/neco-look', {
      \ 'depends': ['Shougo/neocomplete.vim'],
      \ 'on_i': 1,
      \ }
" }}}

" Mac 専用
if has('macunix')
  NeoBundleLazy 'msanders/cocoa.vim', {'on_ft':  ['objc']}
  NeoBundleLazy 'rizzatti/dash.vim',  {'on_cmd': ['Dash'], 'gui': 1}
else
  NeoBundleLazy 'rkitover/vimpager'
endif

if ! has('kaoriya')
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
