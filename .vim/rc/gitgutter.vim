let g:gitgutter_sign_added='➕'
let g:gitgutter_sign_modified='✒'
let g:gitgutter_sign_removed='❌'
let g:gitgutter_sign_modified_removed='⚡'
let g:gitgutter_diff_args='-w --histogram'

nnoremap [g :<c-u>call GitGutterPrevHunk(v:count1)<CR>
nnoremap ]g :<c-u>call GitGutterNextHunk(v:count1)<CR>
