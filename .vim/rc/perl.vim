"-----------------------------------------------------------------------------
" Perl 関連
let perl_include_pod=1
autocmd BufNewFile,BufRead *.psgi set filetype=perl

" zencoding-vim
let g:user_zen_settings = {
\   'indentation' : '    ',
\   'lang' : 'ja',
\   'perl' : {
\       'aliases' : {
\           'req' : 'require '
\       },
\       'snippets' : {
\           'use' : "#!/usr/bin/perl;\nuse utf8;\nuse strict\nuse warnings\nuse errors -with_using;\nuse feature qw! say !;\n\n",
\           'moose' : "#!/usr/bin/perl;\nuse utf8;\nuse Moose;\nuse errors -with_using;\nuse feature qw! say !;\n\n|\n\n__PACKAGE__->meta->make_immutable;",
\       }
\   }
\}
let g:user_zen_expandabbr_key = '<c-q>'
let g:user_zen_complete_tag = 1

"-----------------------------------------------------------------------------
" vim-perl
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
let perl_nofold_subs = 1
unlet! perl_fold_anonymous_subs
