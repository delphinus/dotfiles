-- WezTerm screen copy mode
-- Open terminal screen text in Neovim for navigation and copying
-- Supports multi-pane layouts with scrollback via floating windows
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

-- Global options
vim.opt.laststatus = 0
vim.opt.cmdheight = 0
vim.opt.swapfile = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"

-- Read layout file
local layout_file = vim.env.WEZTERM_COPY_LAYOUT
local layout = nil

if layout_file then
  local f = io.open(layout_file, "r")
  if f then
    layout = vim.json.decode(f:read "*a")
    f:close()
  end
end

-- Create floating windows for each pane
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      if not layout or not layout.panes or #layout.panes == 0 then
        return
      end

      -- Background window: dark empty buffer for gaps between panes
      local bg_buf = vim.api.nvim_get_current_buf()
      vim.bo[bg_buf].buftype = "nofile"
      vim.wo.winhighlight = "Normal:WinSeparator"

      local active_win = nil
      for _, p in ipairs(layout.panes) do
        local buf = vim.fn.bufadd(p.file)
        vim.fn.bufload(buf)
        vim.bo[buf].modifiable = false
        vim.bo[buf].readonly = true
        vim.bo[buf].swapfile = false

        local win = vim.api.nvim_open_win(buf, false, {
          relative = "editor",
          row = p.top,
          col = p.left,
          width = p.width,
          height = p.height,
          style = "minimal",
          border = "none",
          focusable = true,
        })

        vim.wo[win].wrap = true
        vim.wo[win].cursorline = true

        vim.api.nvim_set_current_win(win)
        vim.cmd "normal! Gzb"

        p.win_id = win
        if p.is_active then
          active_win = win
        end
      end

      if active_win then
        vim.api.nvim_set_current_win(active_win)
      end
    end)
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

-- Cleanup all temp files on exit
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    if layout and layout.panes then
      for _, p in ipairs(layout.panes) do
        os.remove(p.file)
      end
    end
    if layout_file then
      os.remove(layout_file)
    end
  end,
})
