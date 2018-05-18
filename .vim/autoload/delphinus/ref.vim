if ! dein#is_sourced('vital.vim') | call dein#source('vital.vim') | endif

let s:V = vital#vital#new()
let s:P = s:V.import('Prelude')

function! delphinus#ref#perl_module_edit(...) abort
  if a:0 > 0
    let module = a:1
  elseif exists('b:ref_perldoc_word')
    let module = b:ref_perldoc_word
  else
    echo 'No module specified'
    return
  endif

  let perldoc_cmd = s:P.is_string(g:ref_perldoc_cmd) ? split(g:ref_perldoc_cmd, '\s\+') : g:ref_perldoc_cmd
  let res = ref#system(perldoc_cmd + ['-l', module])

  if res.stdout ==# ''
    echo printf('No module found for "%s".', module)
  else
    execute 'edit ' . res.stdout
  endif
endfunction
