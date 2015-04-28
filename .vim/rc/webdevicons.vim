let g:WebDevIconsUnicodeDecorateFolderNodesDefaultSymbol = ''

" Settings for the default filter
let name = 'webdevicons'
let filters = {'name': name}

function filters.filter(candidates, context)
  for candidate in a:candidates
    if has_key(candidate, 'webdevicon')
      continue
    endif
    let path = candidate.word
    let is_directory = isdirectory(path)
    let candidate.webdevicon = WebDevIconsGetFileTypeSymbol(path, is_directory)
    let original = has_key(candidate, 'abbr') ? candidate.abbr : candidate.word
    let candidate.abbr = candidate.webdevicon . '  ' . original
  endfor
  return a:candidates
endfunction

call unite#define_filter(filters)
call unite#custom_source('buffer_tab', 'converters', [name])
call unite#custom_source('dwm',        'converters', [name])
call unite#custom_source('file_mru',   'converters', [name])
call unite#filters#converter_default#use([name])
