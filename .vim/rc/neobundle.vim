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

call neobundle#begin(expand(g:bundle_dir))

let g:neobundle#default_options._ = {'verbose': 1}

let s:bundles      = g:rc_dir . '/neobundle.toml'
let s:lazy_bundles = g:rc_dir . '/neobundlelazy.toml'

if neobundle#load_cache(expand('<sfile>'), s:bundles, s:lazy_bundles)
  NeoBundleFetch 'Shougo/neobundle.vim'

  call neobundle#load_toml(s:bundles)
  call neobundle#load_toml(s:lazy_bundles, {'lazy': 1})

  NeoBundleSaveCache
endif

let s:is_vimproc_bundled = isdirectory(expand('$VIM/plugins/vimproc'))
if ! (has('macunix') && has('kaoriya') && s:is_vimproc_bundled)
  NeoBundle 'Shougo/vimproc.vim', {'build': {
        \   'cygwin': 'make -f make_cygwin.mak',
        \   'mac':    'make -f make_mac.mak',
        \   'unix':   'make -f make_unix.mak',
        \ }}
endif

if ! has('kaoriya')
  NeoBundle 'elzr/vim-json'
endif

if has('vim_starting')
  execute 'set runtimepath+=' . g:home
endif

call neobundle#end()

filetype plugin indent on
syntax enable

if !has('vim_starting')
  NeoBundleCheck
  call neobundle#call_hook('on_source')
endif

" vim:se et fdm=marker:
