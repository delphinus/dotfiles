-- See https://github.com/wbthomason/dotfiles/blob/063850b4957a55c065f795722163efc88ffb1b42/neovim/.config/nvim/lua/plugins.lua
local packer
local function init()
  if packer == nil then
    packer = require'packer'
    packer.init{
      disable_commands = true,
      max_jobs = 30,
      display = {
        -- open_fn = require'packer.util'.float,
        -- https://github.com/tjdevries/config_manager/blob/0c89222a53baf997371de0ec1ca4056b834a4d62/xdg_config/nvim/lua/tj/plugins.lua#L331
        open_fn = function(name)
          local last_win = vim.api.nvim_get_current_win()
          local last_pos = vim.api.nvim_win_get_cursor(last_win)

          local ok, win = pcall(function()
            vim.cmd[[packadd plenary.nvim]]
            return require'plenary.window.float'.percentage_range_window(0.8, 0.8)
          end)

          if not ok then
            vim.cmd'65vnew [packer]'
            return true, vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
          end

          vim.api.nvim_buf_set_name(win.bufnr, name)
          vim.api.nvim_win_set_option(win.win_id, 'winblend', 10)

          function _G.restore_cursor()
            vim.api.nvim_set_current_win(last_win)
            vim.api.nvim_win_set_cursor(last_win, last_pos)
          end

          nvim_create_augroups{
            packer_wipe_out = {
              {'BufWipeout', '<buffer>', 'lua restore_cursor()'},
            },
          }

          return true, win.win_id, win.bufnr
        end,
      },
    }
  end
  packer.reset()

  for _, name in pairs{
    'start',
    'opt',
    'denite',
    'lsp',
  } do packer.use(require('packers.'..name)) end
end

return setmetatable({}, {
  __index = function(_, key)
    init()
    return packer[key]
  end,
})
