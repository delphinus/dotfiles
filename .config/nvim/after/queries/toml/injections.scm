((pair
  (bare_key) @_key
  (string) @vim)
 (#vim-match? @_key "^hook_\w*"))
((table
  (bare_key) @_key
  (pair
    (string) @vim))
  (#eq? @_key "ftplugin"))
((table
  (dotted_key) @_key
  (pair
    (string) @vim))
  (#eq? @_key "plugins.ftplugin"))
