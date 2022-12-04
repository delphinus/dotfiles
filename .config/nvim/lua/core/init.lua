pcall(require, "impatient")

local fn, uv, api = require("core.utils").globals()

vim.env.PATH = vim.env.PATH or "/usr/local/bin:/usr/bin:/bin"

if vim.env.NVIM_PROFILE then
  require("plenary.profile").start("/tmp/profile.log", { flame = true })
  api.create_autocmd("VimEnter", {
    callback = function()
      require("plenary.profile").stop()
    end,
  })
end

local pack = require "core.pack"
pack:load_script()

require "core.options"

vim.g.loaded_getscriptPlugin = true
vim.g.loaded_logiPat = true
vim.g.loaded_rrhelper = true
vim.g.loaded_vimballPlugin = true
if fn.has "gui_running" ~= 1 then
  vim.g.plugin_scrnmode_disable = true
end

local local_vimrc = uv.os_homedir() .. "/.vimrc-local"
local st = uv.fs_stat(local_vimrc)
if st and st.type == "file" then
  vim.cmd.source(local_vimrc)
end

require("core.utils").export_globals()
