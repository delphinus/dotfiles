(atx_heading
  (atx_h1_marker) @text.emphasis @text.underline
  (heading_content) @text.emphasis @text.underline
)

(inline_link) @attribute
(link_text) @string

(collapsed_reference_link) @attribute
(collapsed_reference_link (link_text) @attribute @string)
(link_label) @attribute @string
(image) @attribute
(image_description) @string @text.emphasis

; TODO: This makes Neovim too slow.
;(inline_link (link_text) @attribute)
;(image (image_description) @text.emphasis)

(block_quote) @comment

(fenced_code_block
  .
  (code_fence_content) @text.literal
)
