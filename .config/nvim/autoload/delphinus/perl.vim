"if ! dein#is_sourced('vital.vim') | call dein#source('vital.vim') | endif
packadd vital.vim

let s:V = vital#vital#new()
let s:P = s:V.import('Prelude')
let s:FP = s:V.import('System.Filepath')

let s:plenv_carton = '/usr/local/opt/plenv/shims/carton'
let s:cpanm_carton = 'carton'
let s:carton = executable(s:plenv_carton) ? s:plenv_carton :
      \ executable(s:cpanm_carton) ? s:cpanm_carton :
      \ ''
let s:cpanfile = 'cpanfile'
let s:print_perlpath = " -e 'print join(q/,/,@INC)'"

function! delphinus#perl#manage_local_perl(path) abort
  if exists('b:perl_info')
    let perl_info = b:perl_info
  else
    let perl_info = delphinus#perl#perl_info(a:path)
    let b:perl_info = perl_info
  endif

  let g:perlpath = perl_info.perlpath
  let &l:path = g:perlpath
  let b:ale_perl_perl_executable = perl_info.local_perl
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
      let cmdopt = 'exec -- perl -Ilib'

    " plenv without carton
    elseif executable('plenv')
      let local_perl = systemlist('plenv which perl')[0]

    " perlbrew
    elseif filereadable(expand('$HOME/perl5/perlbrew/etc/bashrc'))
      let local_perl = systemlist('source $HOME/perl5/perlbrew/etc/bashrc && which perl')[0]

    " other
    else
      let local_perl = 'perl'
    endif

    let perlpath = pwd . '/lib,'
    if local_perl ==# s:carton
      let perl_info[pwd] = {'local_perl': local_perl, 'perlpath': perlpath, 'cmdopt': cmdopt}
    elseif exists('cmdopt')
      let perlpath .= systemlist(local_perl . ' ' . cmdopt . s:print_perlpath)[0]
      let perl_info[pwd] = {'local_perl': local_perl, 'perlpath': perlpath, 'cmdopt': cmdopt}
    else
      let perlpath .= systemlist(local_perl . s:print_perlpath)[0]
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
