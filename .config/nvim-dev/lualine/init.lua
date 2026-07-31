local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

-- Basic settings for a clean demo
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.showmode = false
vim.opt.laststatus = 3
vim.opt.mouse = "a"
vim.opt.conceallevel = 3

require("lazy").setup {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = { flavour = "mocha" },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme "catppuccin"
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "FocusLost", "CursorHold" },
    opts = {
      current_line_blame = true,
    },
  },

  {
    dir = vim.fn.expand "~/.local/share/nvim/lazy/ghsigns.nvim",
    dependencies = { "lewis6991/gitsigns.nvim" },
    config = function()
      require("ghsigns").setup()
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup {
        options = {
          theme = "catppuccin",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            require("ghsigns.lualine").component(),
          },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "diagnostics" },
          lualine_y = {},
          lualine_z = { "location" },
        },
      }
    end,
  },
}
