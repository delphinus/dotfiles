" Language:      Test::Base - based test with Perl
" Maintainer:    delphinus@remora.cx
" Author:        delphinus@remora.cx
" Homepage:      ~
" Bugs/requests: ~
" Last Change:   {{LAST_CHANGE}}

if exists("b:current_syntax")
    finish
endif

runtime! syntax/yaml.vim
unlet b:current_syntax


syntax include @Perl $VIMRUNTIME/syntax/perl.vim
syntax region TestBasePerl start='\%^' end='^__\%(END\|DATA\)__$' contains=@Perl keepend
syntax include @YAML $VIMRUNTIME/syntax/yaml.vim
syntax region TestBaseYAML start='__\%(END\|DATA\)__\n\zs' end='\%$' contains=@YAML keepend

syntax match TestBaseTitle     '^===.*$'
syntax match TestBaseCondition '^---.\+$'
syntax region TestBaseUnit start='^===' end='\n\ze===\|\%$' transparent fold
syntax sync fromstart
highlight default link TestBaseTitle     Type
highlight default link TestBaseCondition Keyword
set foldmethod=syntax

let b:current_syntax = "test-base"
