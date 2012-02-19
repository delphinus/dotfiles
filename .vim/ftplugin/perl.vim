setl fdm=marker
setl mp=perl\ -c\ %:p
if is_office
    setl noet
else
    setl et
endif
compiler perl
