function! delphinus#init#easyalign#hook_source() abort
  let g:easy_align_delimiters = {
        \ '>': { 'pattern': '>>\|=>\|>' },
        \ '/': { 'pattern': '//\+\|/\*\|\*/', 'ignore_groups': ['String'] },
        \ '#': { 'pattern': '#\+', 'ignore_groups': ['String'], 'delimiter_align': 'l' },
        \ ']': {
        \     'pattern':       '[[\]]',
        \     'left_margin':   0,
        \     'right_margin':  0,
        \     'stick_to_left': 0
        \   },
        \ ')': {
        \     'pattern':       '[()]',
        \     'left_margin':   0,
        \     'right_margin':  0,
        \     'stick_to_left': 0
        \   },
        \ 'd': {
        \     'pattern': ' \(\S\+\s*[;=]\)\@=',
        \     'left_margin': 0,
        \     'right_margin': 0
        \   }
        \ }
endfunction
