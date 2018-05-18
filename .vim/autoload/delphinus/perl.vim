if ! dein#is_sourced('vital.vim') | call dein#source('vital.vim') | endif

let s:V = vital#vital#new()
let s:P = s:V.import('Prelude')
let s:FP = s:V.import('System.Filepath')

let s:plenv_carton = expand('/usr/local/opt/plenv/shims/carton')
let s:perlbrew_carton = expand('carton')
let s:carton = executable(s:plenv_carton) ? s:plenv_carton :
      \ executable(s:perlbrew_carton) ? s:perlbrew_carton :
      \ ''
let s:local_perl = expand('$HOME/git/dotfiles/bin/local_perl.sh')
let s:cpanfile = 'cpanfile'
let s:print_perlpath = " -e 'print join(q/,/,@INC)'"

function! delphinus#perl#manage_local_perl(path) abort
  if exists('b:perl_info')
    let perl_info = b:perl_info
  else
    let perl_info = delphinus#perl#perl_info(a:path)
    let b:perl_info = perl_info
  endif

  if ! exists('g:quickrun_config')
    let g:quickrun_config = {}
  endif

  let g:perlpath = perl_info.perlpath
  let g:quickrun_config['watchdogs_checker/perl'] = get(g:quickrun_config, 'watchdogs_checker/perl', {})
  let g:quickrun_config['watchdogs_checker/perl'].command = perl_info.local_perl
  let g:quickrun_config['watchdogs_checker/perl'].cmdopt = get(perl_info, 'cmdopt', get(g:, 'local_perl_cmdopt', ''))
endfunction

function! delphinus#perl#perl_info(path) abort
  let pwd = s:P.path2project_directory(a:path)
  let cache_key = 'perl_info'
  let memory_perl_info = delphinus#cache#memory().get(cache_key, {})
  if has_key(memory_perl_info, pwd)
    return memory_perl_info[pwd]
  endif

  let perl_info = delphinus#cache#file().get(cache_key, {})

  if ! has_key(perl_info, pwd)

    " plenv with carton
    if filereadable(s:FP.join(pwd, s:cpanfile)) && executable(s:carton)
      let local_perl = s:carton
      let cmdopt = 'exec -- perl'

    " plenv without carton
    elseif executable('plenv')
      let local_perl = systemlist('plenv which perl')[0]

    " perlbrew
    elseif filereadable(expand('$HOME/perl5/perlbrew/etc/bashrc'))
      let local_perl = systemlist('source $HOME/perl5/perlbrew/etc/bashrc && which perl')[0]

    " local_perl
    elseif executable(s:local_perl)
      let local_perl = system(s:local_perl . ' ' . pwd)
      let cmdopt = '-Iapp/lib -Iapp/t/lib -Iapp/extlib/lib/perl5 -Iapp/extlib/lib/perl5/i386-linux-thread-multi'

    " other
    else
      let local_perl = 'perl'
    endif

    if local_perl ==# s:carton
      let perl_info[pwd] = {'local_perl': local_perl, 'perlpath': '', 'cmdopt': cmdopt}
    elseif exists('cmdopt')
      let perlpath = systemlist(local_perl . ' ' . cmdopt . s:print_perlpath)[0]
      let perl_info[pwd] = {'local_perl': local_perl, 'perlpath': perlpath, 'cmdopt': cmdopt}
    else
      let perlpath = systemlist(local_perl . s:print_perlpath)[0]
      let perl_info[pwd] = {'local_perl': local_perl, 'perlpath': perlpath}
    endif
    call delphinus#cache#file().set(cache_key, perl_info)
  endif

  call delphinus#cache#memory().set(cache_key, perl_info)

  return perl_info[pwd]
endfunction

function! delphinus#perl#test_filetype() abort
  if &filetype ==# 'perl'
    return
  endif
  for ele in s:FP.split(expand('%'))
    if ele ==# 't' || ele ==# 'xt'
      set filetype=perl
      return
    endif
  endfor
endfunction
