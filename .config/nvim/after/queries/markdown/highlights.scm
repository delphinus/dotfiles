;; extends

(atx_heading
  (atx_h1_marker) @text.emphasis @text.underline
  (inline) @text.emphasis @text.underline
)

(link_label) @attribute @string

; TODO: This makes Neovim too slow.
;(inline_link (link_text) @attribute)
;(image (image_description) @text.emphasis)

(block_quote) @comment

(fenced_code_block
  .
  (code_fence_content) @text.literal
)
