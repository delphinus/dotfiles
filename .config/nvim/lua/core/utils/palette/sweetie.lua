---@class core.utils.palette.sweetie.Colors
---@field is_dark boolean
---@field [string] string
local colors = require("sweetie.colors").get_palette(vim.o.background)
colors.is_dark = vim.o.background == "dark"
colors.black = colors.is_dark and colors.bg or colors.fg
colors.white = colors.is_dark and colors.fg or colors.bg
return colors
