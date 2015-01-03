" quickrun
" 他のと干渉するのでマッピングはしない
let g:quickrun_no_default_key_mappings=1
" 必要なモジュールをロード
let g:quickrun_perl_modules = '-MYAML -M"HTTP::Date qw.str2time time2iso." -MDateTime -MDate::Manip -Mutf8 -MIO::All'

if !exists('g:quickrun_config')
    let g:quickrun_config = {}
endif

let g:quickrun_config['perl'] = {
            \ 'exec': '%c %o %s',
            \ 'command': 'perl',
            \ 'cmdopt': '%{g:quickrun_perl_modules}',
            \ 'eval': 1,
            \ 'eval_template': 'no strict;binmode STDOUT,":utf8";$e=eval{%s};print$e?Dump($e):$@',
            \ 'runner' : 'vimproc',
            \ }

let myperl = expand('/usr/local/opt/plenv/shims/perl')
if executable(myperl)
    let g:quickrun_config['perl'].command = myperl
endif

let g:quickrun_config.applescript = {'command' : 'osascript' , 'output' : '_'}

" ビジュアルモードで選択した部分を実行
command! -range R :QuickRun perl -mode v
"command! R :QuickRun perl -mode v
