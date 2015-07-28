let perl_include_pod=1
let perl_include_pod = 1
unlet! perl_no_scope_in_variables
unlet! perl_no_extended_vars
let perl_string_as_statement = 1
unlet! perl_no_sync_on_sub
unlet! perl_no_sync_on_global_var
let perl_sync_dist = 100
let perl_fold = 1
unlet! perl_fold_blocks
let perl_nofold_packages = 1
unlet! perl_nofold_subs
let perl_fold_anonymous_subs = 1

set iskeyword-=-
set iskeyword-=:
if exists(':NeoCompleteIncludeMakeCache')
  augroup NeoCompleteIncludeMakeCacheForPerl
    autocmd!
    autocmd BufWritePost <buffer> NeoCompleteIncludeMakeCache
  augroup END
endif

if filereadable('.noexpandtab') || (len($USER) && $USER ==# 'game')
    setlocal noexpandtab
    setlocal tabstop=4
    setlocal shiftwidth=4
    setlocal softtabstop=4
endif

call delphinus#perl#manage_local_perl()
