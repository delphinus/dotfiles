local lualine_require = require "lualine_require"
local M = lualine_require.require("lualine.component"):extend()

function M:init(options)
  local palette = require "core.utils.palette"
  local colors = palette.colors
  M.super.init(self, options)
  self.highlights = {
    cwd = self:create_hl({ fg = colors.cyan }, "cwd"),
    dirname = self:create_hl({ fg = colors.teal or colors.blue }, "dir"),
    basename = self:create_hl({ fg = colors.yellow, gui = "bold" }, "dir"),
  }
  self.home_re = "^" .. assert(vim.uv.os_homedir()) .. "/"
  self.ghe_re = vim.env.GITHUB_ENTERPRISE_HOST and "^~/git/" .. vim.pesc(vim.env.GITHUB_ENTERPRISE_HOST) .. "/" or nil
  self.nvim_re = "^" .. vim.pesc(vim.env.VIMRUNTIME) .. "/"
  self.obsidian_re = vim.pesc "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/"
  self.stdpaths = vim
    .iter({ "cache", "config", "data", "state", "log", "run" })
    :map(function(name)
      return {
        name = "" .. name .. ":",
        re = "^"
          .. (
            vim.pesc((vim.fn.stdpath(name) --[[@as string]]):gsub(self.home_re, "~/"))
          )
          .. "/",
      }
    end)
    :totable()
end

function M:update_status()
  local colors = vim.iter(self.highlights):fold({}, function(a, k, v)
    a[k] = self:format_hl(v)
    return a
  end)
  if vim.o.buftype == "terminal" then
    return colors.cwd .. "TERMINAL"
  end
  local cwd = assert(vim.uv.cwd()) .. "/"
  local filename = vim.api.nvim_buf_get_name(0)
  return table.concat({
    colors.cwd .. self:cwd(cwd),
    colors.dirname .. self:dirname(cwd, filename),
    colors.basename .. self:basename(filename),
  }, "")
end

function M:prettier(dir)
  local replaced = dir
    :gsub(self.home_re, "~/")
    :gsub("^~/git/dotfiles/", " ")
    :gsub("^~/git/github%.com/", " ")
    :gsub(self.nvim_re, " ")
    :gsub(self.obsidian_re, " ")
  if self.ghe_re then
    dir = dir:gsub(self.ghe_re, "󰦑 ")
  end
  return vim.iter(self.stdpaths):fold(replaced, function(a, b)
    return (a:gsub(b.re, b.name))
  end)
end

function M:cwd(cwd)
  return self:prettier(cwd)
end

function M:dirname(cwd, filename)
  if filename == "" then
    return ""
  end
  local dirname = vim.fs.dirname(filename) .. "/"
  if dirname:find(cwd, 1, true) then
    return #dirname == #cwd and "" or dirname:sub(#cwd + 1)
  end
  return " " .. self:prettier(dirname)
end

function M:basename(filename)
  return vim.fs.basename(filename)
end

return M
