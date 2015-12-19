augroup LoadPlantUML
  autocmd!
  autocmd BufRead,BufNewFile * :if getline(1) =~ '^.*startuml.*$'|  setfiletype plantuml | endif
  autocmd BufRead,BufNewFile *.pu,*.uml,*.plantuml setfiletype plantuml
augroup END
