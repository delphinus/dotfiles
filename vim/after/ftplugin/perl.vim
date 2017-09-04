let g:perl_include_pod=1
let g:perl_include_pod = 1
unlet! g:perl_no_scope_in_variables
unlet! g:perl_no_extended_vars
let g:perl_string_as_statement = 1
unlet! g:perl_no_sync_on_sub
unlet! g:perl_no_sync_on_global_var
let g:perl_sync_dist = 100
let g:perl_fold = 1
unlet! g:perl_fold_blocks
let g:perl_nofold_packages = 1
unlet! g:perl_nofold_subs
let g:perl_fold_anonymous_subs = 1
let g:perl_sub_signatures = 1

set iskeyword-=-
set iskeyword-=:
if exists(':NeoCompleteIncludeMakeCache')
  augroup NeoCompleteIncludeMakeCacheForPerl
    autocmd!
    autocmd BufWritePost <buffer> NeoCompleteIncludeMakeCache
  augroup END
endif

if filereadable('.noexpandtab')
  setlocal noexpandtab
endif

setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4
