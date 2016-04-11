function! delphinus#init#gista#hook_post_source() abort
  let l:apinames = gista#client#get_available_apinames()
  if index(l:apinames, 'GHE') == -1 && exists('g:delphinus#init#gista#apiurl')
    call gista#client#register('GHE', g:delphinus#init#gista#apiurl)
  endif
endfunction
