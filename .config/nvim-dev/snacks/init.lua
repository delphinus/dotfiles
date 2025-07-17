vim.pack.add({
  "https://github.com/folke/snacks.nvim",
}, { load = false })

vim.keymap.set("n", "<leader><space>", function()
  require("snacks").picker.smart()
end, { desc = "Smart Find Files" })
vim.keymap.set("n", "<leader>gb", function()
  require("snacks").picker.git_branches()
end, { desc = "Git Branches" })
