" シンタックスチェック
" http://d.hatena.ne.jp/osyo-manga/20110921/1316605254

" quickfix のエラー箇所を波線でハイライト
highlight qf_error ctermbg=red ctermfg=white gui=undercurl
let g:hier_highlight_group_qf='qf_error'

" quickfix に出力して、ポップアップはしない outputter/quickfix
" すでに quickfix ウィンドウが開いている場合は閉じるので注意
let s:silent_quickfix=quickrun#outputter#quickfix#new()
function! s:silent_quickfix.finish(session)
    call call(quickrun#outputter#quickfix#new().finish, [a:session], self)
    cclose
    " vim-hier の更新
    HierUpdate
    " quickfix への出力後に quickfixstatus を有効に
    QuickfixStatusEnable
endfunction
" quickfix に登録
call quickrun#register_outputter('silent_quickfix', s:silent_quickfix)

" シンタックスチェック用の quickrun.vim のコンフィグ
" perl 用
let g:quickrun_config['PerlSyntaxCheck'] = {
            \ 'type': 'perl',
            \ 'exec': '%c %o %s:p',
            \ 'command': g:vim_home . '/vimparse.pl',
            \ 'cmdopt': '-c ',
            \ 'outputter': 'silent_quickfix',
            \ 'runner': 'vimproc'
            \ }

let g:quickrun_config['CppSyntaxCheck'] = {
            \ 'type': 'cpp',
            \ 'exec': '%c %o %s:p',
            \ 'command': "g++",
            \ 'cmdopt': ' ',
            \ 'outputter': 'silent_quickfix',
            \ 'runner': 'vimproc'
            \ }


" ファイルの保存後に quickrun.vim が実行されるように設定する
"autocmd BufWritePost *.pl,*.pm,*.t :QuickRun PerlSyntaxCheck
"autocmd BufWritePost *.cpp,*.h,*.hpp :QuickRun CppSyntaxCheck

" vim:et:
