scriptencoding utf-8

function! delphinus#init#watchdogs#hook_source() abort
  let g:quickrun_config = get(g:, 'quickrun_config', {})

  " 書き込み後にシンタックスチェックを行う
  let g:watchdogs_check_BufWritePost_enable = 1

  " 一定時間キー入力がなかった場合にシンタックスチェックを行う
  " バッファに書き込み後、1度だけ行われる
  let g:watchdogs_check_CursorHold_enable = 1

  " 起動後に quickfix ウィンドウを開かない
  let g:quickrun_config['watchdogs_checker/_'] = {
        \ 'hook/close_quickfix/enable_exit':        1,
        \ 'hook/back_window/enable_exit':           0,
        \ 'hook/back_window/priority_exit':         1,
        \ 'hook/qfstatusline_update/enable_exit':   1,
        \ 'hook/qfstatusline_update/priority_exit': 2,
        \ 'outputter/quickfix/open_cmd': '',
        \ }

  let g:quickrun_config['watchdogs_checker/gcc'] = {'cmdopt': '-std=c99'}
  let g:quickrun_config['watchdogs_checker/jshint'] = {'cmdopt': '--config ' . g:home . '/git/dotfiles/.jshintrc'}

  let s:rbenv_ruby = expand('/usr/local/opt/rbenv/shims/ruby')
  if executable(s:rbenv_ruby)
    let g:quickrun_config['watchdogs_checker/ruby'] = {'command': s:rbenv_ruby}
  endif

  let s:phpcs = expand(g:home . '/.composer/vendor/bin/phpcs')
  if executable(s:phpcs)
    let s:errorformat =
          \ '%-GFile\,Line\,Column\,Type\,Message\,Source\,Severity%.%#,'.
          \ '"%f"\,%l\,%c\,%t%*[a-zA-Z]\,"%m"\,%*[a-zA-Z0-9_.-]\,%*[0-9]%.%#'
    let g:quickrun_config['watchdogs_checker/php'] = {
          \ 'quickfix/errorformat': s:errorformat,
          \ 'command':              s:phpcs,
          \ 'cmdopt':               '--report=csv',
          \ 'exec':                 '%c %o %s:p',
          \ }
    let g:quickrun_config['php.wordpress/watchdogs_checker'] = {
          \ 'type':   'watchdogs_checker/php',
          \ 'cmdopt': '--report=csv --standard=WordPress-Extra',
          \ }
  endif

  " Use tsuquyomi syntax check instead of watchdogs
  let g:watchdogs_check_BufWritePost_enables = {
        \ 'typescript': 0,
        \ }
  let g:watchdogs_check_CursorHold_enables = {
        \ 'typescript': 0,
        \ }
endfunction

function! delphinus#init#watchdogs#hook_post_source() abort
  call watchdogs#setup(g:quickrun_config)
endfunction
