"
" gather candidates
"
function! unite#sources#rails#collector#typescripts#candidates(source) abort
  let target = a:source.source__rails_root . '/frontend/typescripts'
  return unite#sources#rails#helper#gather_candidates_file(target)
endfunction

