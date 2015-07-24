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

let s:V = vital#of('vital')
let s:P = s:V.import('Prelude')

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
  let s:perl = system('source $HOME/perl5/perlbrew/etc/bashrc && which perl')
  let s:perl = substitute(s:perl, '\n', '', 'g')
  let g:perlpath = system(s:perl . s:print_perlpath)
  let g:quickrun_config['watchdogs_checker/perl'].command = s:perl
  let g:quickrun_config['watchdogs_checker/perl'].cmdopt = '-Ilib -It/lib'

" local_perl
elseif executable(s:local_perl)
  let s:pwd = s:P.path2project_directory(expand('%'))
  if ! exists('g:watchdogs_local_perl')
    let g:watchdogs_local_perl = {}
  endif
  if ! exists("g:watchdogs_local_perl['" . s:pwd . "']")
    let g:watchdogs_local_perl[s:pwd] = {}
    let g:watchdogs_local_perl[s:pwd].local_perl = system(s:local_perl . ' ' . s:pwd)
    let g:watchdogs_local_perl[s:pwd].perlpath = system(g:watchdogs_local_perl[s:pwd]['local_perl'] . s:print_perlpath)
  endif
  let g:perlpath = g:watchdogs_local_perl[s:pwd].perlpath
  let g:quickrun_config['watchdogs_checker/perl'].command = g:watchdogs_local_perl[s:pwd]['local_perl']
  let g:quickrun_config['watchdogs_checker/perl'].cmdopt = '-Iapp/lib -Iapp/t/lib -Iapp/extlib/lib/perl5 -Iapp/extlib/lib/perl5/i386-linux-thread-multi'

" other
else
  let g:perlpath = systemlist('perl' . s:print_perlpath)[0]
  let g:quickrun_config['watchdogs_checker/perl'].cmdopt = '-Ilib -It/lib'
endif
