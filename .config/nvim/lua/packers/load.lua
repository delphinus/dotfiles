-- See https://github.com/wbthomason/dotfiles/blob/063850b4957a55c065f795722163efc88ffb1b42/neovim/.config/nvim/lua/plugins.lua
local init = (function()
  local packer
  return function()
    if packer == nil then
      vim.cmd [[packadd packer.nvim]]
      packer = require "packer"
      packer.init {
        -- TODO: use impatient.nvim
        compile_path = fn.stdpath "config" .. "/lua/packer_compiled.lua",
        compile_on_sync = false,
        profile = {
          enable = false,
          threshold = 1,
        },
        disable_commands = true,
        max_jobs = 50,
        display = {
          -- open_fn = require'packer.util'.float,
          -- https://github.com/tjdevries/config_manager/blob/0c89222a53baf997371de0ec1ca4056b834a4d62/xdg_config/nvim/lua/tj/plugins.lua#L331
          open_fn = function(name)
            local ok, win = pcall(function()
              vim.cmd [[packadd plenary.nvim]]
              return require("plenary.window.float").percentage_range_window(0.8, 0.8)
            end)

            if not ok then
              vim.cmd "65vnew [packer]"
              return true, api.get_current_win(), api.get_current_buf()
            end

            api.buf_set_name(win.bufnr, name)
            api.win_set_option(win.win_id, "winblend", 10)
            return true, win.win_id, win.bufnr
          end,
        },
      }
    end
    packer.reset()

    for _, name in pairs {
      "start",
      "opt",
      "ddc",
      "lsp",
      "telescope",
    } do
      packer.use(require("packers." .. name))
    end

    return packer
  end
end)()

return setmetatable({}, {
  __index = function(_, key)
    return init()[key]
  end,
})
