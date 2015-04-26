" 書き込み後にシンタックスチェックを行う
let g:watchdogs_check_BufWritePost_enable = 1

" こっちは一定時間キー入力がなかった場合にシンタックスチェックを行う
" バッファに書き込み後、1度だけ行われる
let g:watchdogs_check_CursorHold_enable = 1

let g:quickrun_config['watchdogs_checker/gcc'] = {
      \ 'cmdopt': '-std=c99',
      \ }
let g:quickrun_config['watchdogs_checker/jshint'] = {
      \ 'cmdopt': '--config ' . g:home . '/git/dotfiles/.jshintrc'
      \ }

let rbenv_ruby = expand('/usr/local/opt/rbenv/shims/ruby')
if executable(rbenv_ruby)
  let g:quickrun_config['watchdogs_checker/ruby'] = {
        \ 'command': rbenv_ruby,
        \ }
endif

let phpcs = expand(g:home . '/.composer/vendor/bin/phpcs')
if executable(phpcs)
  let errorformat =
        \ '%-GFile\,Line\,Column\,Type\,Message\,Source\,Severity%.%#,'.
        \ '"%f"\,%l\,%c\,%t%*[a-zA-Z]\,"%m"\,%*[a-zA-Z0-9_.-]\,%*[0-9]%.%#'
  let g:quickrun_config['watchdogs_checker/php'] = {
        \ 'quickfix/errorformat': errorformat,
        \ 'command':              phpcs,
        \ 'cmdopt':               '--report=csv',
        \ 'exec':                 '%c %o %s:p',
        \ }
  let g:quickrun_config['php.wordpress/watchdogs_checker'] = {
        \ 'type':   'watchdogs_checker/php',
        \ 'cmdopt': '--report=csv --standard=WordPress-Extra',
        \ }
endif

let g:quickrun_config['watchdogs_checker/_'] = {
      \ 'outputter/quickfix/open_cmd': ''
      \ }

" この関数に g:quickrun_config を渡す
" この関数で g:quickrun_config にシンタックスチェックを行うための設定を追加する
" 関数を呼び出すタイミングはユーザの g:quickrun_config 設定後
call watchdogs#setup(g:quickrun_config)
