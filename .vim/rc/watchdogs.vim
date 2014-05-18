" 書き込み後にシンタックスチェックを行う
let g:watchdogs_check_BufWritePost_enable = 1

" こっちは一定時間キー入力がなかった場合にシンタックスチェックを行う
" バッファに書き込み後、1度だけ行われる
let g:watchdogs_check_CursorHold_enable = 0

let g:quickrun_config['watchdogs_checker/gcc'] = {
            \ 'cmdopt': '-std=c99',
            \ }
let g:quickrun_config['watchdogs_checker/jshint'] = {
            \ 'cmdopt': '--config ' . g:home . '/git/dotfiles/.jshintrc'
            \ }

let cargon = expand('/usr/local/opt/plenv/shims/carton')
if executable(myperl)
    let g:quickrun_config['watchdogs_checker/perl'] = {
                \ 'command': carton,
                \ 'cmdopt': 'exec -- perl -Ilib',
                \ }
else
    let g:quickrun_config['watchdogs_checker/perl'] = {
                \ 'cmdopt': '-Ilib',
                \ }
endif

" この関数に g:quickrun_config を渡す
" この関数で g:quickrun_config にシンタックスチェックを行うための設定を追加する
" 関数を呼び出すタイミングはユーザの g:quickrun_config 設定後
call watchdogs#setup(g:quickrun_config)
