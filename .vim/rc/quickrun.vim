let g:quickrun_no_default_key_mappings=1

for [s:key, s:com] in items({
      \ 'x': '>message',
      \ 's': '-runner shell',
      \ 'w': '-runner vimproc >buffer',
      \ 'q': '-runner vimproc >>buffer',
      \ })
  execute 'nnoremap <silent>' '<Leader>q' . s:key ':QuickRun' s:com '-mode n<CR>'
  execute 'vnoremap <silent>' '<Leader>q' . s:key ':QuickRun' s:com '-mode v<CR>'
endfor
