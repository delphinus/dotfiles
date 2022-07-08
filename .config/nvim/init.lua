-- Define utility functions in global
_G.fn = vim.fn
_G.loop = vim.loop
_G.api = setmetatable({ _cache = {} }, {
  __index = function(self, name)
    if not self._cache[name] then
      local func = vim.api["nvim_" .. name]
      if func then
        self._cache[name] = func
      else
        error("Unknown api func: " .. name, 2)
      end
    end
    return self._cache[name]
  end,
})

vim.env.PATH = vim.env.PATH or "/usr/local/bin:/usr/bin:/bin"

if vim.env.NVIM_PROFILE then
  require("plenary.profile").start("/tmp/profile.log", { flame = true })
  api.create_autocmd("VimEnter", {
    callback = function()
      require("plenary.profile").stop()
    end,
  })
end

require "setup"
require "packers"
require "set"
require "mapping"
require "term"
require "commands"

vim.g.loaded_getscriptPlugin = true
vim.g.loaded_logiPat = true
vim.g.loaded_rrhelper = true
vim.g.loaded_vimballPlugin = true
if fn.has "gui_running" ~= 1 then
  vim.g.plugin_scrnmode_disable = true
end

local local_vimrc = loop.os_homedir() .. "/.vimrc-local"
local st = loop.fs_stat(local_vimrc)
if st and st.type == "file" then
  vim.cmd("source " .. local_vimrc)
end
