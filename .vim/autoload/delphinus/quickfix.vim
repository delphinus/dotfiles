" Automatically fitting a quickfix window height - Vim Tips Wiki - Wikia
" http://vim.wikia.com/wiki/Automatically_fitting_a_quickfix_window_height
function! delphinus#quickfix#set_height(min_height, max_height) abort
  let l:line = 1
  let l:line_count = 0
  let l:winwidth = winwidth(0)
  while l:line <= line('$')
    " number to float for division
    let l:line_length = strlen(getline(l:line)) + 0.0
    let l:line_width = l:line_length / l:winwidth
    let l:line_count += float2nr(ceil(l:line_width))
    let l:line += 1
  endwhile
  execute max([min([l:line_count, a:max_height]), a:min_height]) . 'wincmd _'
endfunction
