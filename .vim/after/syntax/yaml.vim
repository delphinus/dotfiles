syntax match TestBaseTitle     '^===.*$'
syntax match TestBaseCondition '^---.\+$'
syntax region TestBaseUnit start='^===' end='\n\ze===\|\%$' transparent fold
syntax sync fromstart
highlight default link TestBaseTitle     Type
highlight default link TestBaseCondition Keyword
set foldmethod=syntax
