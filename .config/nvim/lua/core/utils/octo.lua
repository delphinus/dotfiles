local palette = require "core.utils.palette"

---@class core.utils.octo.Octo
---@field current_host string
---@field enterprise_host string
---@field github_host string
---@field default_config table
local Octo = {}

---@return core.utils.octo.Octo
Octo.new = function()
  local enterprise_host = vim.env.GITHUB_ENTERPRISE_HOST
  return setmetatable({
    current_host = enterprise_host,
    enterprise_host = enterprise_host,
    github_host = "github.com",
    default_config = {
      user_icon = "",
      outdated_icon = "󰅒",
      resolved_icon = "",
      colors = {
        white = palette.colors.white,
        grey = palette.colors.bright_black,
        black = palette.colors.black,
        red = palette.colors.brighter_red,
        dark_red = palette.colors.red,
        green = palette.colors.green,
        dark_green = palette.colors.nord7,
        yellow = palette.colors.yellow,
        dark_yellow = palette.colors.orange,
        blue = palette.colors.blue,
        dark_blue = palette.colors.dark_blue,
        purple = palette.colors.magenta,
      },
    },
  }, { __index = Octo })
end

---@return table
function Octo:config()
  return vim.tbl_extend(
    "force",
    self.default_config,
    { github_hostname = self:is_enterprise() and self.current_host or nil }
  )
end

---@return boolean
function Octo:is_enterprise()
  return self.current_host == self.enterprise_host
end

---@return boolean
function Octo:is_loaded()
  return not not require("lazy.core.config").plugins["octo.nvim"]._.loaded
end

---@return string?
function Octo:current_repo()
  local buffer = octo_buffers[api.get_current_buf()]
  if buffer then
    return buffer.repo
  end
  local layout = require("octo.reviews").get_current_layout()
  if layout then
    return layout.file_panel.files[1].pull_request.repo
  end
end

---@return nil
function Octo:toggle()
  self.current_host = self:is_enterprise() and self.github_host or self.enterprise_host
  self:setup()
end

---@return nil
function Octo:setup()
  _G.octo_repo_issues = {}
  _G.octo_buffers = {}
  require("octo").setup(self:config())
end

return Octo.new()
