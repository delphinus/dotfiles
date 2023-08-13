;; extends

(fenced_code_block
  (info_string) @lang
  (code_fence_content) @injection.content
  (#vim-match? @lang "^(sh|bash|shell)$")
  (#set! injection.language "bash")
)

(fenced_code_block
  (info_string) @lang
  (code_fence_content) @injection.content
  (#vim-match? @lang "^prompt$")
  (#set! injection.language "bash")
)

(fenced_code_block
  (info_string) @lang
  (code_fence_content) @injection.content
  (#vim-match? @lang "^(vim)(:.*)?$")
  (#set! injection.language vim)
)

(fenced_code_block
  (info_string) @lang
  (code_fence_content) @injection.content
  (#vim-match? @lang "^(lua)(:.*)?$")
  (#set! injection.language lua)
)
