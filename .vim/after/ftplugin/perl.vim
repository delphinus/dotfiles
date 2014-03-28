set iskeyword-=-
set iskeyword-=:
autocmd BufWritePost <buffer> NeoCompleteIncludeMakeCache

if is_office_alt
    setl et
elseif is_office
    setl noet
else
    setl et
endif

Rooter
