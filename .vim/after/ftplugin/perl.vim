let perl_include_pod=1
let perl_include_pod = 1
unlet! perl_no_scope_in_variables
unlet! perl_no_extended_vars
let perl_string_as_statement = 1
unlet! perl_no_sync_on_sub
unlet! perl_no_sync_on_global_var
let perl_sync_dist = 100
let perl_fold = 1
unlet! perl_fold_blocks
let perl_nofold_packages = 1
unlet! perl_nofold_subs
let perl_fold_anonymous_subs = 1

let s:cache_dir = expand('$HOME/.cache/vim')
let s:V = vital#of('vital')
let s:P = s:V.import('Prelude')
let s:C = s:V.import('System.Cache.File')
let s:cache = s:C.new({'cache_dir': s:cache_dir})

set iskeyword-=-
set iskeyword-=:
if exists(':NeoCompleteIncludeMakeCache')
  augroup NeoCompleteIncludeMakeCacheForPerl
    autocmd!
    autocmd BufWritePost <buffer> NeoCompleteIncludeMakeCache
  augroup END
endif

if filereadable('.noexpandtab') || (len($USER) && $USER ==# 'game')
    setlocal noexpandtab
    setlocal tabstop=4
    setlocal shiftwidth=4
    setlocal softtabstop=4
endif

let g:perlpath = ''
let s:carton = expand('/usr/local/opt/plenv/shims/carton')
let s:local_perl = expand('$HOME/git/dotfiles/bin/local_perl.sh')
let s:cpanfile = 'cpanfile'
let s:print_perlpath = " -e 'print join(q/,/,@INC)'"

function! s:manage_local_perl(perl_type)
  let pwd = s:P.path2project_directory(expand('%'))
  let cache_key = 'perl_cache'
  let perl_cache = s:cache.get(cache_key, {})
  if ! has_key(perl_cache, pwd)

    if a:perl_type ==# 'local_perl'
      let perl_cache[pwd] = {
            \ 'local_perl': system(s:local_perl . ' ' . pwd),
            \ 'perlpath':   system(g:watchdogs_local_perl[pwd]['local_perl'] . s:print_perlpath),
            \ }
      let g:quickrun_config['watchdogs_checker/perl'].cmdopt = '-Iapp/lib -Iapp/t/lib -Iapp/extlib/lib/perl5 -Iapp/extlib/lib/perl5/i386-linux-thread-multi'

    elseif a:perl_type ==# 'perlbrew'
      let perl = system('source $HOME/perl5/perlbrew/etc/bashrc && which perl')
      let perl = substitute(perl, '\n', '', 'g')
      let perl_cache[pwd] = {
            \ 'local_perl': perl,
            \ 'perlpath': system(perl . s:print_perlpath),
            \ }
      let g:quickrun_config['watchdogs_checker/perl'].cmdopt = '-Ilib -It/lib'
    endif

    call s:cache.set(cache_key, perl_cache)
  endif
  let g:perlpath = perl_cache[pwd].perlpath
  let g:quickrun_config['watchdogs_checker/perl'].command = perl_cache[pwd].local_perl
endfunction

" plenv with carton
if filereadable(s:cpanfile) && executable(s:carton)
  let perlpath = systemlist(s:carton . ' exec -- perl' . s:print_perlpath)[0]
  let g:quickrun_config['watchdogs_checker/perl'].command = s:carton
  let g:quickrun_config['watchdogs_checker/perl'].cmdopt = 'exec -- perl -Ilib -It/lib'

" plenv without carton
elseif executable('plenv')
  let s:perl = systemlist('plenv which perl')[0]
  let perlpath = system(s:perl . s:print_perlpath)
  let g:quickrun_config['watchdogs_checker/perl'].command = s:perl
  let g:quickrun_config['watchdogs_checker/perl'].cmdopt = '-Ilib -It/lib'

" perlbrew
elseif filereadable(expand('$HOME/perl5/perlbrew/etc/bashrc'))
  call s:manage_local_perl('perlbrew')

" local_perl
elseif executable(s:local_perl)
  call s:manage_local_perl('local_perl')

" other
else
  let g:perlpath = systemlist('perl' . s:print_perlpath)[0]
  let g:quickrun_config['watchdogs_checker/perl'].cmdopt = '-Ilib -It/lib'
endif
