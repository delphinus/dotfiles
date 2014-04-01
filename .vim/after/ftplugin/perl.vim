set iskeyword-=-
set iskeyword-=:
if exists(':NeoCompleteIncludeMakeCache')
    autocmd BufWritePost <buffer> NeoCompleteIncludeMakeCache
endif

if exists('is_office_alt') && is_office_alt
    setlocal expandtab
elseif exists('is_office') && is_office
    setlocal noexpandtab
else
    setlocal expandtab
endif

if exists(':Rooter')
    Rooter
endif
