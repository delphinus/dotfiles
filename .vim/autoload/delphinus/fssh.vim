function! delphinus#fssh#fetch_env() abort
  let env_cmd = len($TMUX) ? 'tmux showenv' : 'env'
  let env = {}
  for line in systemlist(env_cmd . ' | grep LC_FSSH_')
    let [tmp, name, value] = matchlist(line, '^\([^=]\+\)=\(.*\)$')[:2]
    let env[name] = value
  endfor
  return env
endfunction

function! delphinus#fssh#is_enabled() abort
  let env = delphinus#fssh#fetch_env()
  return len(get(env, 'LC_FSSH_PORT', ''))
endfunction

function! delphinus#fssh#execute(command) abort
  let tmpfile = tempname()
  call writefile([a:command], tmpfile)
  let env = delphinus#fssh#fetch_env()
  let cmd = printf("ssh -p %d -l %s %s localhost PATH=%s 'bash -s' < %s",
        \ env['LC_FSSH_PORT'],
        \ env['LC_FSSH_USER'],
        \ env['LC_FSSH_COPY_ARGS'],
        \ env['LC_FSSH_PATH'],
        \ tmpfile,
        \ )
  echo 'fssh execute: ' . a:command
  call system(cmd)
endfunction

function! delphinus#fssh#open(url) abort
  call delphinus#fssh#execute('open ' . a:url)
endfunction

function! delphinus#fssh#copy() abort
  if ! delphinus#fssh#is_enabled()
    echoerr 'fssh is not enabled!'
    return
  endif

  let error = systemlist('ui_copy', split(@", '\n'))
  if len(error)
    echoerr string(error)
  else
    echo 'copied from @" to system clipboard'
  endif
endfunction
