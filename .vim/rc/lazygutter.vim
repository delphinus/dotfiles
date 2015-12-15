scriptencoding utf-8
let g:gitgutter_enabled=0
let g:gitgutter_sign_added=''
let g:gitgutter_sign_modified=''
let g:gitgutter_sign_removed=''
let g:gitgutter_sign_modified_removed=''
let g:gitgutter_diff_args='-w --histogram'

set <M-g>=g
nmap <M-g> :GitGutterToggle<CR>
