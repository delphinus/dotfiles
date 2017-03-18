scriptencoding utf-8

function! delphinus#init#gitgutter#hook_source() abort
  let g:gitgutter_diff_args='-w --compaction-heuristic'
  let g:gitgutter_enabled=1
  let g:gitgutter_highlight_lines = 1
  let g:gitgutter_sign_added=''
  let g:gitgutter_sign_modified=''
  let g:gitgutter_sign_modified_removed=''
  let g:gitgutter_sign_removed=''
endfunction

function! delphinus#init#gitgutter#hook_post_source() abort
  nmap [h <Plug>GitGutterPrevHunk
  nmap ]h <Plug>GitGutterNextHunk
  hi GitGutterAddLine ctermbg=233 guibg=#122b0c
  hi GitGutterChangeLine ctermbg=236 guibg=#342e0e
  hi GitGutterDeleteLine ctermbg=235 guibg=#4e2728
endfunction
