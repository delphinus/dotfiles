local m = require "mappy"
m.add_buffer_maps(function()
  m.nmap("<C-i>", "O")
  m.rbind({ "<A-b>", "<A-∫>", "<C-o>" }, "o")
  m.rbind({ "<C-c>", "<CR>", "<Esc>" }, "q")
end)
