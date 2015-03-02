set iskeyword-=-
set iskeyword-=:
if exists(':NeoCompleteIncludeMakeCache')
    autocmd BufWritePost <buffer> NeoCompleteIncludeMakeCache
endif

if exists(':Rooter')
    Rooter
endif

if filereadable('.noexpandtab') || (len($USER) && $USER == 'game')
    setlocal noexpandtab
    setlocal tabstop=4
    setlocal shiftwidth=4
    setlocal softtabstop=4
endif

let carton = expand('/usr/local/opt/plenv/shims/carton')
if executable(carton)
  let g:quickrun_config['watchdogs_checker/perl']['command'] = carton
  let g:quickrun_config['watchdogs_checker/perl']['cmdopt'] = 'exec -- perl -Ilib -It/lib'
elseif filereadable(expand('$HOME/perl5/perlbrew/etc/bashrc'))
  redir => s:perl
  silent !source $HOME/perl5/perlbrew/etc/bashrc && which perl
  redir END
  let s:perl = substitute(split(s:perl, '\r')[1], '\n', '', 'g')
  let g:quickrun_config['watchdogs_checker/perl']['command'] = s:perl
  let g:quickrun_config['watchdogs_checker/perl']['cmdopt'] = '-Ilib -It/lib'
else
  let g:quickrun_config['watchdogs_checker/perl']['cmdopt'] = '-Ilib -It/lib'
endif
