let s:V = vital#of('vital')
let s:P = s:V.import('Prelude')
let s:FP = s:V.import('System.Filepath')

let s:carton = expand('/usr/local/opt/plenv/shims/carton')
let s:local_perl = expand('$HOME/git/dotfiles/bin/local_perl.sh')
let s:cpanfile = 'cpanfile'
let s:print_perlpath = " -e 'print join(q/,/,@INC)'"

function! delphinus#perl#manage_local_perl(path) abort
  if exists('b:perl_info')
    let l:perl_info = b:perl_info
  else
    let l:perl_info = delphinus#perl#perl_info(a:path)
    let b:perl_info = l:perl_info
  endif

  if ! exists('g:quickrun_config')
    let g:quickrun_config = {}
  endif

  let g:perlpath = l:perl_info.perlpath
  let g:quickrun_config['watchdogs_checker/perl'] = get(g:quickrun_config, 'watchdogs_checker/perl', {})
  let g:quickrun_config['watchdogs_checker/perl'].command = l:perl_info.local_perl
  let g:quickrun_config['watchdogs_checker/perl'].cmdopt = get(l:perl_info, 'cmdopt', '-Ilib -It/lib')
endfunction

function! delphinus#perl#perl_info(path) abort
  let l:pwd = s:P.path2project_directory(a:path)
  let l:cache_key = 'perl_info'
  let l:memory_perl_info = delphinus#cache#memory().get(l:cache_key, {})
  if has_key(l:memory_perl_info, l:pwd)
    return l:memory_perl_info[l:pwd]
  endif

  let l:perl_info = delphinus#cache#file().get(l:cache_key, {})

  if ! has_key(l:perl_info, l:pwd)

    " plenv with carton
    if filereadable(s:FP.join(l:pwd, s:cpanfile)) && executable(s:carton)
      let l:local_perl = s:carton
      let l:cmdopt = 'exec -- perl'

    " plenv without carton
    elseif executable('plenv')
      let l:local_perl = systemlist('plenv which perl')[0]

    " perlbrew
    elseif filereadable(expand('$HOME/perl5/perlbrew/etc/bashrc'))
      let l:local_perl = systemlist('source $HOME/perl5/perlbrew/etc/bashrc && which perl')[0]

    " local_perl
    elseif executable(s:local_perl)
      let l:local_perl = system(s:local_perl . ' ' . l:pwd)
      let l:cmdopt = '-Iapp/lib -Iapp/t/lib -Iapp/extlib/lib/perl5 -Iapp/extlib/lib/perl5/i386-linux-thread-multi'

    " other
    else
      let l:local_perl = 'perl'
    endif

    if l:local_perl ==# s:carton
      let l:perl_info[l:pwd] = {'local_perl': l:local_perl, 'perlpath': '', 'cmdopt': l:cmdopt}
    elseif exists('l:cmdopt')
      let l:perlpath = systemlist(l:local_perl . ' ' . l:cmdopt . s:print_perlpath)[0]
      let l:perl_info[l:pwd] = {'local_perl': l:local_perl, 'perlpath': l:perlpath, 'cmdopt': l:cmdopt}
    else
      let l:perlpath = systemlist(l:local_perl . s:print_perlpath)[0]
      let l:perl_info[l:pwd] = {'local_perl': l:local_perl, 'perlpath': l:perlpath}
    endif
    call delphinus#cache#file().set(l:cache_key, l:perl_info)
  endif

  call delphinus#cache#memory().set(l:cache_key, l:perl_info)

  return l:perl_info[l:pwd]
endfunction

function! delphinus#perl#test_filetype() abort
  if &filetype ==# 'perl'
    return
  endif
  for l:ele in s:FP.split(expand('%'))
    if l:ele ==# 't' || l:ele ==# 'xt'
      set filetype=perl
      return
    endif
  endfor
endfunction
