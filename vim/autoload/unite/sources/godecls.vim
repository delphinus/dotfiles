let s:save_cpo = &cpoptions
set cpoptions&vim

let s:source = {
      \ 'name': 'godecls',
      \ 'description': 'GoDecls implementation by unite source',
      \ 'syntax': 'uniteSource__GoDecls',
      \ 'action_table': {},
      \ 'hooks': {},
      \ }

function! unite#sources#godecls#define()
  return s:source
endfunction

function! s:source.gather_candidates(args, context) abort
  let l:bin_path = go#path#CheckBinPath('motion')
  if empty(l:bin_path)
    return []
  endif

  let l:path = expand(get(a:args, 0, '%:p:h'))
  if isdirectory(l:path)
    let l:mode = 'dir'
  elseif filereadable(l:path)
    let l:mode = 'file'
  else
    return []
  endif

  let l:include = get(g:, 'go_decls_includes', 'func,type')
  let l:command = printf('%s -format vim -mode decls -include %s -%s %s', l:bin_path, l:include, l:mode, l:path)
  let l:result = eval(unite#util#system(l:command))
  let l:candidates = get(l:result, 'decls', [])

  return map(l:candidates, "{
        \ 'word': printf('%s :%d :%s', fnamemodify(v:val.filename, ':~:.'), v:val.line, v:val.full),
        \ 'kind': 'jump_list',
        \ 'action__path': v:val.filename,
        \ 'action__line': v:val.line,
        \ 'action__col': v:val.col,
        \ }")
endfunction

function! s:source.hooks.on_syntax(args, context) abort
  syntax match uniteSource__GoDecls_Filepath /[^:]*\ze:/ contained containedin=uniteSource__GoDecls
  syntax match uniteSource__GoDecls_Line /\d\+\ze :/ contained containedin=uniteSource__GoDecls
  syntax match uniteSource__GoDecls_WholeFunction /\vfunc %(\([^)]+\) )?[^(]+/ contained containedin=uniteSource__GoDecls
  syntax match uniteSource__GoDecls_Function /\S\+\ze(/ contained containedin=uniteSource__GoDecls_WholeFunction
  syntax match uniteSource__GoDecls_WholeType /type \S\+/ contained containedin=uniteSource__GoDecls
  syntax match uniteSource__GoDecls_Type /\v( )@<=\S+/ contained containedin=uniteSource__GoDecls_WholeType
  highlight default link uniteSource__GoDecls_Filepath Comment
  highlight default link uniteSource__GoDecls_Line LineNr
  highlight default link uniteSource__GoDecls_Function Function
  highlight default link uniteSource__GoDecls_Type Type

  syntax match uniteSource__GoDecls_Separator /:/ contained containedin=uniteSource__GoDecls conceal
  syntax match uniteSource__GoDecls_SeparatorFunction /func / contained containedin=uniteSource__GoDecls_WholeFunction conceal
  syntax match uniteSource__GoDecls_SeparatorType /type / contained containedin=uniteSource__GoDecls_WholeType conceal
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
