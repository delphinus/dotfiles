scriptencoding utf-8

function! delphinus#unite#my_setting() abort
  " vimfiler で開く
  nnoremap <silent> <buffer> <expr> <C-O> unite#do_action('vimfiler')
  inoremap <silent> <buffer> <expr> <C-O> unite#do_action('vimfiler')
  " dwm.vim で開く
  nnoremap <silent> <buffer> <expr> <C-N> unite#do_action('dwm_new')
  inoremap <silent> <buffer> <expr> <C-N> unite#do_action('dwm_new')
  " rec/async で開く
  nnoremap <silent> <buffer> <expr> <C-A> unite#do_action('rec/async')
  inoremap <silent> <buffer> <expr> <C-A> unite#do_action('rec/async')
  " rec_parent/async で開く
  nnoremap <silent> <buffer> <expr> <C-P> unite#do_action('rec_parent/async')
  inoremap <silent> <buffer> <expr> <C-P> unite#do_action('rec_parent/async')
  " rec_project/async で開く
  nnoremap <silent> <buffer> <expr> <C-R> unite#do_action('rec_project/async')
  inoremap <silent> <buffer> <expr> <C-R> unite#do_action('rec_project/async')
  " タブで開く
  nnoremap <silent> <buffer> <expr> <C-T> unite#do_action('tabopen')
  inoremap <silent> <buffer> <expr> <C-T> unite#do_action('tabopen')
  " grep で開く
  nnoremap <silent> <buffer> <expr> <C-G> unite#do_action('grep')
  inoremap <silent> <buffer> <expr> <C-G> unite#do_action('grep')
  " 終了して一つ前に戻る
  nmap <silent> <buffer> <ESC><ESC> <Plug>(unite_exit)
  imap <silent> <buffer> <ESC><ESC> <Plug>(unite_exit)
  " Unite ウィンドウを閉じる
  imap <silent> <buffer> <C-C> <Esc><C-C>
  " インサートモードで上下移動
  imap <silent> <buffer> <C-K> <Plug>(unite_select_previous_line)
  imap <silent> <buffer> <C-J> <Plug>(unite_select_next_line)
  " ノーマルモードで上下移動
  nmap <silent> <buffer> <C-K> <Plug>(unite_select_previous_line)
  nmap <silent> <buffer> <C-J> <Plug>(unite_select_next_line)
  " 一つ上のパスへ
  imap <buffer> <C-U> <Plug>(unite_delete_backward_path)
  " 入力した文字を消す
  imap <buffer> <C-W> <Plug>(unite_delete_backward_word)
endfunction
