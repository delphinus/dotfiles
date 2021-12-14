-- Perl highlighting for Carp keywords
-- Maintainer:   vim-perl <vim-perl@groups.google.com>
-- Installation: Put into after/syntax/perl/carp.vim

vim.cmd[[
  syntax match perlStatementProc "\<\%(croak\|confess\|carp\|cluck\)\>"
]]
