local M = {}

---@param style "storm"|"night"|"moon"|"day"
---@return table
function M.make(style)
  local c = require("tokyonight.colors").setup { style = style }
  local palette = vim.tbl_extend("force", {}, c)

  palette.is_dark = style ~= "day"

  -- Keep tokyonight's `c.black` (= bg blended toward pure black, slightly
  -- darker than Normal bg). It's a useful accent / border color.
  palette.white = c.fg
  palette.bright_black = c.terminal_black
  palette.bright_red = c.red1
  palette.bright_green = c.green1
  palette.bright_yellow = c.yellow
  palette.bright_blue = c.blue1
  palette.bright_magenta = c.magenta2
  palette.bright_cyan = c.cyan
  palette.bright_white = c.fg

  palette.dark_black = c.bg_dark
  palette.dark_white = c.fg_dark
  palette.dark_blue = c.blue0
  palette.dark_grey = c.dark3
  palette.gray = c.fg_gutter
  palette.brighter_black = c.dark5
  palette.brighter_red = c.red1
  palette.brighter_blue = c.blue1

  local Util = require "tokyonight.util"
  ---@param hex string
  ---@param amount number
  local function bg(hex, amount)
    return Util.blend_bg(hex, amount, c.bg)
  end
  palette.bg_red = bg(c.red, 0.25)
  palette.bg_green = bg(c.green, 0.25)
  palette.bg_yellow = bg(c.yellow, 0.25)
  palette.bg_blue = bg(c.blue, 0.25)
  palette.bg_orange = bg(c.orange, 0.25)
  palette.bg_purple = bg(c.purple, 0.25)
  palette.bg_magenta = bg(c.magenta, 0.25)
  palette.bg_cyan = bg(c.cyan, 0.25)

  palette.context = c.bg_highlight

  return palette
end

return M
