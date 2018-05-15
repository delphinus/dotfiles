" Automatically fitting a quickfix window height - Vim Tips Wiki - Wikia
" http://vim.wikia.com/wiki/Automatically_fitting_a_quickfix_window_height
function! delphinus#quickfix#set_height(min_height, max_height) abort
  let line = 1
  let line_count = 0
  let winwidth = winwidth(0)
  while line <= line('$')
    " number to float for division
    let line_length = strlen(getline(line)) + 0.0
    let line_width = line_length / winwidth
    let line_count += float2nr(ceil(line_width))
    let line += 1
  endwhile
  execute max([min([line_count, a:max_height]), a:min_height]) . 'wincmd _'
endfunction
