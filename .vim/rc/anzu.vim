" n の後に anzu-mode を開始する
nmap n <Plug>(anzu-mode-n)
" N の後に anzu-mode を開始する
nmap N <Plug>(anzu-mode-N)

" n や N の代わりに使用します。
"nmap n <Plug>(anzu-n)
"nmap N <Plug>(anzu-N)
"nmap * <Plug>(anzu-star)
"nmap # <Plug>(anzu-sharp)

" g* 時にステータス情報を出力する場合
nmap g* g*<Plug>(anzu-update-search-status-with-echo)

" 最後に検索したワードの [count] の位置へ移動する
" 10<Leader>j であれば先頭から10番目のワードの位置へ移動する
"nmap <Leader>j <Plug>(anzu-jump)
" ステータス情報をコマンドラインに出力する場合はこちら
"nmap <Leader>j <Plug>(anzu-jump)<Plug>(anzu-echo-search-status)
nmap <Leader>n <Plug>(anzu-jump)<Plug>(anzu-echo-search-status)

" ステータス情報を statusline へと表示する
"set statusline=%{anzu#search_status()}

" こちらを使用すると
" 移動後にステータス情報をコマンドラインへと出力を行います。
" nmap n <Plug>(anzu-n-with-echo)
" nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)

" sign も一緒に使用する場合
" nmap n <Plug>(anzu-n-with-echo)<Plug>(anzu-sign-matchline)
" nmap N <Plug>(anzu-N-with-echo)<Plug>(anzu-sign-matchline)

