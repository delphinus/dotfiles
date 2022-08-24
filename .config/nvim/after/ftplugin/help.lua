vim.opt.list = false
vim.opt.number = false
vim.opt.relativenumber = false
vim.b.cursorword = 0

local name = "colorscheme_ft_help"
local ns = api.get_namespaces()[name]
if not ns then
  ns = api.create_namespace(name)
  api.set_hl(ns, "Comment", { fg = "#c29d53", italic = true })
end
api.win_set_hl_ns(0, ns)
