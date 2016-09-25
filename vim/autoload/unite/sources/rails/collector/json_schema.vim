"
" gather candidates
"
function! unite#sources#rails#collector#json_schema#candidates(source)
  let target = a:source.source__rails_root . '/schema'
  return unite#sources#rails#helper#gather_candidates_file(target)
endfunction
