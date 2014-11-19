set iskeyword-=-
set iskeyword-=:
if exists(':NeoCompleteIncludeMakeCache')
    autocmd BufWritePost <buffer> NeoCompleteIncludeMakeCache
endif

if exists(':Rooter')
    Rooter
endif

if filereadable('.noexpandtab') || (len($USER) && $USER == 'game')
    setlocal noexpandtab
    setlocal tabstop=4
    setlocal shiftwidth=4
    setlocal softtabstop=4
endif
