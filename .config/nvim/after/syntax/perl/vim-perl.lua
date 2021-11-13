-- added lacked Test::More keyaords
api.exec([[
  syntax match perlStatementProc "\<\%(todo\|todo_skip\|eq_array\|eq_hash\|eq_set\|$TODO\|done_testing\|note\|explain\|subtest\)\>"
]], false)
