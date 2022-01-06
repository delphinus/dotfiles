-- Perl highlighting for SQL in heredocs
-- Maintainer:   vim-perl <vim-perl@groups.google.com>
-- Installation: Put into after/syntax/perl/heredoc-sql.vim

-- XXX include guard

-- XXX make the dialect configurable?
vim.cmd [[runtime! syntax/mysql.vim]]
vim.b.current_syntax = nil
vim.cmd [[syntax include @SQL syntax/mysql.vim]]

if vim.g.perl_fold == 0 then
  vim.cmd [[
    syntax region perlHereDocSQL matchgroup=perlStringStartEnd start=+<<\s*'\z(\%(END_\)\=SQL\)'+ end='^\z1$' contains=@SQL               fold extend
    syntax region perlHereDocSQL matchgroup=perlStringStartEnd start='<<\s*"\z(\%(END_\)\=SQL\)"' end='^\z1$' contains=@perlInterpDQ,@SQL fold extend
    syntax region perlHereDocSQL matchgroup=perlStringStartEnd start='<<\s*\z(\%(END_\)\=SQL\)'   end='^\z1$' contains=@perlInterpDQ,@SQL fold extend
  ]]
else
  vim.cmd [[
    syntax region perlHereDocSQL matchgroup=perlStringStartEnd start=+<<\s*'\z(\%(END_\)\=SQL\)'+ end='^\z1$' contains=@SQL
    syntax region perlHereDocSQL matchgroup=perlStringStartEnd start='<<\s*"\z(\%(END_\)\=SQL\)"' end='^\z1$' contains=@perlInterpDQ,@SQL
    syntax region perlHereDocSQL matchgroup=perlStringStartEnd start='<<\s*\z(\%(END_\)\=SQL\)'   end='^\z1$' contains=@perlInterpDQ,@SQL
  ]]
end
