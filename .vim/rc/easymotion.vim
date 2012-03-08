" 使う文字
let g:EasyMotion_keys='hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
" 2 ストローク選択を優先する
let g:EasyMotion_grouping=2
" カラー設定変更
if !has('gui')
    hi EasyMotionTarget ctermbg=none ctermfg=green
    hi EasyMotionShade  ctermbg=none ctermfg=blue
endif
