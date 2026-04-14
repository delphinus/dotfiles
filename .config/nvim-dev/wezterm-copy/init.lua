-- WezTerm screen copy mode
-- Open terminal screen text in Neovim for navigation and copying
-- Uses flash.nvim + luamigemo for fuzzy-motion

local shared = vim.env.HOME .. "/.local/share/nvim/lazy"
vim.opt.rtp:prepend(shared .. "/lazy.nvim")

require("lazy").setup({
  {
    "delphinus/luamigemo",
    dir = shared .. "/luamigemo",
  },
  {
    "folke/flash.nvim",
    dir = shared .. "/flash.nvim",
    opts = {
      labels = "HJKLASDFGYUIOPQWERTNMZXCVB",
      search = {
        mode = function(str)
          if str == "" then
            return str
          elseif #str < 2 then
            return [[\c]] .. str .. [[\|\%#.]]
          end
          local migemo = require "luamigemo"
          return [[\c]] .. migemo.query(str, migemo.RXOP_VIM)
        end,
      },
    },
  },
}, {
  install = { missing = false },
  change_detection = { enabled = false },
  checker = { enabled = false },
  rocks = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

-- Minimal UI
vim.opt.laststatus = 0
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "no"
vim.opt.ruler = false
vim.opt.showcmd = false
vim.opt.showmode = false
vim.opt.swapfile = false
vim.opt.cursorline = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"

-- Make buffer readonly and jump to viewport position
vim.api.nvim_create_autocmd("BufReadPost", {
  once = true,
  callback = function()
    vim.bo.modifiable = false
    local line = tonumber(vim.env.WEZTERM_COPY_LINE)
    if line then
      local max_line = vim.api.nvim_buf_line_count(0)
      vim.api.nvim_win_set_cursor(0, { math.min(line, max_line), 0 })
      vim.cmd "normal! zt"
    end
  end,
})

-- Flash
vim.keymap.set({ "n", "x" }, "s", function()
  require("flash").jump()
end, { desc = "Flash (migemo)" })

-- Quit
vim.keymap.set("n", "q", "<Cmd>qa!<CR>")

-- Auto-close after yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.defer_fn(function()
      vim.cmd "qa!"
    end, 50)
  end,
})

-- Cleanup temp file on exit
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    local f = vim.fn.expand "%:p"
    if f:match "/wezterm%-copy%-" then
      os.remove(f)
    end
  end,
})
