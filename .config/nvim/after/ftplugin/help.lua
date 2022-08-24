vim.opt.list = false
vim.opt.number = false
vim.opt.relativenumber = false
vim.b.cursorword = 0

local name = "colorscheme_ft_help"
local ns = vim.api.nvim_get_namespaces()[name]
if not ns then
  ns = vim.api.nvim_create_namespace(name)
  vim.api.nvim_set_hl(ns, "Comment", { fg = "#c29d53", italic = true })
end
vim.api.nvim_win_set_hl_ns(0, ns)
