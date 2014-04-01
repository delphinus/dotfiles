" 使う文字
let g:EasyMotion_keys = 'hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
" Leader に ' を設定
let g:EasyMotion_leader_key = "'"
" 1 ストローク選択を優先する
let g:EasyMotion_grouping =1
" 日本語検索
let g:EasyMotion_use_migemo = 1

nmap s <Plug>(easymotion-s2)
xmap s <Plug>(easymotion-s2)
omap s <Plug>(easymotion-s2)
nmap S <Plug>(easymotion-t2)
xmap S <Plug>(easymotion-t2)
omap S <Plug>(easymotion-t2)
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)
map  n <Plug>(easymotion-next)
map  N <Plug>(easymotion-prev)
