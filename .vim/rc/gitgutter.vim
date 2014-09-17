if has('gui_macvim')
  let g:gitgutter_sign_added='►'
  let g:gitgutter_sign_modified='☡'
  let g:gitgutter_sign_removed='✗'
  let g:gitgutter_sign_modified_removed='◄'
else
  let g:gitgutter_sign_added='➕'
  let g:gitgutter_sign_modified='⚡'
  let g:gitgutter_sign_removed='➖'
  let g:gitgutter_sign_modified_removed='🚫'
endif
let g:gitgutter_diff_args='-w --histogram'

nmap [h <Plug>(GitGutterPrevHunk)
nmap ]h <Plug>(GitGutterNextHunk)
