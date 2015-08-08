scriptencoding utf-8

" タイトル文字列指定
set titlestring=%{delphinus#title#string()}

" ウィンドウタイトルを更新する
if &term =~# '^screen'
  set t_ts=k
  set t_fs=\

  " dvtm の場合
elseif &term =~# 'dvtm'
  ' ウィンドウタイトルを変える
  let &t_IS = '\e]1;'
  let &t_ts = '\e]0;'
  let &t_fs = '\007'
endif

if has('gui_running') || &term =~# '^screen' || &term =~# '^xterm' || &term =~# '^dvtm'
  set title
endif

" Vim が終了したらこのタイトルにする
set titleold=bash
