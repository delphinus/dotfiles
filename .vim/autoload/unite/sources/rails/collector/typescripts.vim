"
" gather candidates
"
function! unite#sources#rails#collector#typescripts#candidates(source)
  let target = a:source.source__rails_root . '/app/assets/typescripts'
  if !isdirectory(target)
    let target = a:source.source__rails_root . '/public/typescripts'
  endif
  return unite#sources#rails#helper#gather_candidates_file(target)
endfunction

