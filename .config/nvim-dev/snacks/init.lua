-- Reuse the locally cloned tokyonight from the main config (vim.pack has no
-- "local dir" option, so prepend rtp directly).
vim.opt.rtp:prepend(vim.fn.expand "~/.local/share/nvim/lazy/tokyonight.nvim")

vim.pack.add({
  "https://github.com/folke/snacks.nvim",
}, { load = false })

vim.cmd.colorscheme "tokyonight"

vim.keymap.set("n", "<leader><space>", function()
  require("snacks").picker.smart()
end, { desc = "Smart Find Files" })
vim.keymap.set("n", "<leader>gb", function()
  require("snacks").picker.git_branches()
end, { desc = "Git Branches" })
