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

let carton = expand('/usr/local/opt/plenv/shims/carton')
let perlbrew_setting = expand('$HOME/perl5/perlbrew/etc/bashrc')
if executable(carton)
  let g:quickrun_config['watchdogs_checker/perl'] = {
        \ 'command': carton,
        \ 'cmdopt': 'exec -- perl -Ilib -It/lib',
        \ }
elseif filereadable(perlbrew_setting)
  redir => s:perl
  silent !source $HOME/perl5/perlbrew/etc/bashrc && which perl
  redir END
  let s:perl = substitute(split(s:perl, '\r')[1], '\n', '', 'g')
  let g:quickrun_config['watchdogs_checker/perl'] = {
        \ 'command': s:perl,
        \ 'cmdopt': '-Ilib -It/lib',
        \ }
else
  let g:quickrun_config['watchdogs_checker/perl'] = {
        \ 'cmdopt': '-Ilib -It/lib',
        \ }
endif

let rbenv_ruby = expand('/usr/local/opt/rbenv/shims/ruby')
if executable(rbenv_ruby)
  let g:quickrun_config['watchdogs_checker/ruby'] = {
        \ 'command': rbenv_ruby,
        \ }
endif

" この関数に g:quickrun_config を渡す
" この関数で g:quickrun_config にシンタックスチェックを行うための設定を追加する
" 関数を呼び出すタイミングはユーザの g:quickrun_config 設定後
call watchdogs#setup(g:quickrun_config)
