let g:syntastic_enable_highlighting=0   " ハイライトしない
let g:syntastic_javascript_jsl_conf='-conf ' . g:home . '/bin/jsl.conf' " jsl の設定ファイル
let g:syntastic_perl_lib_path = './lib,./app/lib,./app/t/lib,./JP/pm' " Perl のライブラリパス
let g:syntastic_async=1
function! ToggleSyntastic()
    let s_mode = g:syntastic_mode_map['mode'] == 'active' ? 'passive' : 'active'
    let g:syntastic_mode_map['mode'] = s_mode
    let verb = s_mode == 'active' ? 'Activate' : 'Passivate'
    echo verb . ' Syntastic mode'
endfunction
command! TS :call ToggleSyntastic()
