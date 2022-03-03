require("agrp").set {
  terminal_command = {
    {
      "TermOpen",
      "term://*",
      function()
        vim.opt.scrolloff = 0
        vim.opt.number = false
        vim.opt.relativenumber = false
        vim.opt.cursorline = false
        vim.cmd [[startinsert]]
      end,
    },
    { "WinEnter", "term://*", "startinsert" },
    { "WinEnter", "term://*", "doautocmd <nomodeline> FocusGained %" },
    { "WinLeave", "term://*", "doautocmd <nomodeline> FocusLost %" },
  },
}

for map, keys in
  pairs {
    ["<C-j>"] = { "<A-j>", "<A-∆>" },
    ["<C-k>"] = { "<A-k>", "<A-˚>" },
    ["<C-q>"] = { "<A-q>", "<A-œ>" },
    ["<C-s>"] = { "<A-s>", "<A-ß>" },
    [":"] = { "<A-;>", "<A-…>" },
  }
do
  for _, key in ipairs(keys) do
    vim.keymap.set("t", key, [[<C-\><C-n>]] .. map, { remap = true })
    vim.keymap.set("n", key, map, { remap = true })
  end
end

vim.keymap.set("t", "<A-o>", [[<C-\><C-n><C-w>oi]], { remap = true })
vim.keymap.set("t", "<A-ø>", [[<C-\><C-n><C-w>oi]], { remap = true })
vim.keymap.set("n", "<A-o>", [[<C-w>o]], { remap = true })
vim.keymap.set("n", "<A-ø>", [[<C-w>o]], { remap = true })
vim.keymap.set("t", "<A-CR>", [[<C-\><C-n><A-CR>]], { remap = true })

local function get_register()
  return [[<C-\><C-n>]] .. fn.nr2char(fn.getchar()) .. "pi"
end

vim.keymap.set("t", "<A-r>", get_register, { expr = true })
vim.keymap.set("t", "<A-®>", get_register, { expr = true })
