function! delphinus#devicons#converter() abort
  return {'name': 'devicons', 'filter': function('delphinus#devicons#converter_filter')}
endfunction

function! delphinus#devicons#converter_filter(candidates, context) abort
  if !exists('*WebDevIconsGetFileTypeSymbol')
    return a:candidates
  endif

  for candidate in filter(copy(a:candidates), "!has_key(v:val, 'icon')")
    let raw_path = get(candidate, 'action__path', '')
    if ! filereadable(raw_path) && ! isdirectory(raw_path)
      continue
    endif
    let filename = fnamemodify(raw_path, ':p:t')
    let isdir = isdirectory(raw_path)
    let candidate.icon = WebDevIconsGetFileTypeSymbol(filename, isdir)
    let path = get(candidate, 'word', '')
    if path ==# raw_path
      let path = get(candidate, 'abbr', raw_path)
      if g:neomru#filename_format !=# ''
        let path = fnamemodify(path, g:neomru#filename_format)
        if path ==# ''
          let path = fnamemodify('.', ':~')
        endif
      endif
      if isdir && path !~# '/$'
        let path .= '/'
      endif
    endif
    let candidate.abbr = candidate.icon . ' ' . path
  endfor
  return a:candidates
endfunction

function! delphinus#devicons#mru() abort
  return {'name': 'devicons_mru', 'filter': function('delphinus#devicons#mru_filter')}
endfunction

function! delphinus#devicons#mru_filter(candidates, context) abort
  if g:neomru#filename_format ==# '' && g:neomru#time_format ==# ''
    return a:candidates
  endif

  for candidate in filter(copy(a:candidates), "!has_key(v:val, 'abbr')")
    let raw_path = get(candidate, 'action__path', candidate.word)
    let filename = fnamemodify(raw_path, ':p:t')

    if g:neomru#time_format ==# ''
      let path = raw_path
    else
      let path = unite#util#substitute_path_separator(fnamemodify(raw_path, g:neomru#filename_format))
    endif
    if path ==# ''
      let path = raw_path
    endif

    let candidate.abbr = ''
    if g:neomru#time_format !=# ''
      let candidate.abbr .= strftime(g:neomru#time_format, getftime(raw_path))
    endif

    if exists('*WebDevIconsGetFileTypeSymbol')
      let candidate.abbr .= WebDevIconsGetFileTypeSymbol(filename, isdirectory(raw_path))
      if g:neomru#filename_format ==# ''
        let candidate.abbr .= ' ' . raw_path
      else
        let candidate.abbr .= ' ' . fnamemodify(raw_path, g:neomru#filename_format)
      endif
    else
        let candidate.abbr .= ' ' . raw_path
    endif
  endfor

  return a:candidates
endfunction
