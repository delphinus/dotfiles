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
  let g:quickrun_config['watchdogs_checker/jshint'] = {'cmdopt': '--config ' . $HOME . '/git/dotfiles/.jshintrc'}

  let s:rbenv_ruby = expand('/usr/local/opt/rbenv/shims/ruby')
  if executable(s:rbenv_ruby)
    let g:quickrun_config['watchdogs_checker/ruby'] = {'command': s:rbenv_ruby}
  endif

  " Use other plugin syntax check instead of watchdogs
  let g:watchdogs_check_BufWritePost_enables = {
        \ 'typescript': 0,
        \ 'go': 0,
        \ }
  let g:watchdogs_check_CursorHold_enables = {
        \ 'typescript': 0,
        \ 'go': 0,
        \ }
endfunction

function! delphinus#init#watchdogs#hook_post_source() abort
  call watchdogs#setup(g:quickrun_config)
endfunction
