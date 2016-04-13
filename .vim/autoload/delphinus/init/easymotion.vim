scriptencoding utf-8

function! delphinus#init#easymotion#hook_source() abort
  " 使う文字
  let g:EasyMotion_keys = 'hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
  " 1 ストローク選択を優先する
  let g:EasyMotion_grouping =1
  " 日本語検索
  let g:EasyMotion_use_migemo = 1
  " Space か Enter を押すと最初のマッチに飛ぶ
  let g:EasyMotion_enter_jump_first = 1
  let g:EasyMotion_space_jump_first = 1
endfunction
