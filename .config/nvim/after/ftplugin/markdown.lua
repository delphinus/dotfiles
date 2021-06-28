-- TODO: mappings for VV
local m = require'mappy'
m.add_buffer_maps(function()
  m.nmap('<A-m>', '<Plug>MarkdownPreview')
  m.nmap('<A-M>', '<Plug>StopMarkdownPreview')
end)
