;; extends

(fenced_code_block
  (info_string) @lang
  (code_fence_content) @content
  (#vim-match? @lang "^(sh|bash)$")
  (#set! language "bash")
)

(fenced_code_block
  (info_string) @lang
  (code_fence_content) @content
  (#vim-match? @lang "^prompt$")
  (#set! language "bash")
)
