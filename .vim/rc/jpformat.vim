scriptencoding utf-8
"-----------------------------------------------------------------------------
" JpFormat.vim
" 現在行を整形
nnoremap <silent> gl :JpFormat<CR>
" 現在行が整形対象外でも強制的に整形
nnoremap <silent> gL :JpFormat!<CR>
" 自動整形のON/OFF切替
" 30gc の様にカウント指定すると、折り返し文字数を指定されたカウントに変更します。
nnoremap <silent> g. :JpFormatToggle<CR>

" カーソル位置の分割行をまとめてヤンク
nnoremap <silent> gY :JpYank<CR>
" カーソル位置の分割行をまとめて連結
nnoremap <silent> gJ :JpJoin<CR>

" 整形に gqを使うかどうかをトグルする
nnoremap <silent> gC :JpFormatGqToggle<CR>
" 外部ビューアを起動する
nnoremap <silent> <F8> :JpExtViewer<CR>
" txtファイルで「連結マーカー+改行」が有ったら自動整形を有効にする
augroup JpFormatSetting
  autocmd!
  autocmd BufRead *.txt  silent! call JpSetAutoFormat()
augroup END

" 日本語の行の連結時には空白を入力しない。
set formatoptions+=mM
" iText Expressで開く
let ExtViewer_txt = '!open -a "iText Express" "%f"'
" 外部ビューアに渡すファイル名
let EV_Tempname_txt = '/tmp/.evtemp'
