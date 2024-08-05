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
  self.home_re = "^" .. vim.uv.os_homedir():gsub("%.", "%%.") .. "/"
  self.ghe_re = "^~/git/" .. vim.env.GITHUB_ENTERPRISE_HOST:gsub("%.", "%%.") .. "/"
  self.nvim_re = "^" .. vim.env.VIMRUNTIME:gsub("%.", "%%.") .. "/"
  self.stdpaths = vim
    .iter({ "cache", "config", "data", "log", "run", "state" })
    :map(function(name)
      return {
        name = "" .. name .. ":",
        re = "^"
          .. (
            (vim.fn.stdpath(name) --[[@as string]]):gsub(self.home_re, "~/"):gsub("%.", "%%.")
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
  local cwd = assert(vim.uv.cwd()) .. "/"
  local filename = vim.api.nvim_buf_get_name(0)
  return table.concat({
    colors.cwd .. self:cwd(cwd),
    colors.dirname .. self:dirname(cwd, filename),
    colors.basename .. self:basename(filename),
  }, "")
end

function M:cwd(cwd)
  return vim.iter(self.stdpaths):fold(
    (
      cwd
        :gsub(self.home_re, "~/")
        :gsub("^~/git/dotfiles/", " ")
        :gsub("^~/git/github%.com/", " ")
        :gsub(self.ghe_re, "󰦑 ")
        :gsub(self.nvim_re, " ")
    ),
    function(a, b)
      return (a:gsub(b.re, b.name))
    end
  )
end

function M:dirname(cwd, filename)
  if vim.o.buftype == "terminal" then
    return "TERM"
  end
  if filename == "" then
    return ""
  end
  local dirname = vim.fs.dirname(filename) .. "/"
  return #dirname == #cwd and "" or dirname:sub(#cwd + 1)
end

function M:basename(filename)
  return vim.fs.basename(filename)
end

return M
