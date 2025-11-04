-- Minimal init.lua for testing telescope treesitter picker
-- Usage: env NVIM_APPNAME=nvim-dev/telescope-treesitter nvim

-- Set up package path
local plugins = vim.fn.stdpath "data" .. "/lazy"

-- Install lazy.nvim if not already installed
local lazypath = plugins .. "/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specification
require("lazy").setup({
  {
    "nvim-lua/plenary.nvim",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    -- Change this to "main" or "master" to test different branches
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- Detect which branch we're using based on available APIs
      local has_configs = pcall(require, "nvim-treesitter.configs")

      if has_configs then
        -- Master branch setup
        require("nvim-treesitter.configs").setup {
          ensure_installed = { "lua", "python", "javascript", "typescript" },
          sync_install = true,
          auto_install = false,
          highlight = {
            enable = true,
          },
        }
        print "nvim-treesitter: using master branch API"
      else
        -- Main branch setup
        require("nvim-treesitter").setup {
          install_dir = vim.fn.stdpath "data" .. "/site",
        }
        -- Install parsers synchronously
        require("nvim-treesitter").install({ "lua", "python", "javascript", "typescript" }):wait(60000)
        print "nvim-treesitter: using main branch API"
      end
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    -- Use the local modified version
    dir = vim.fn.expand "~/.local/share/nvim/lazy/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup {}
    end,
  },
}, {
  root = plugins,
})

-- Set up basic options
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true

-- Create a test file with some content
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      -- Create test file
      vim.cmd "edit /tmp/test.lua"

      -- Explicitly set filetype
      vim.bo.filetype = "lua"

      -- Add content if empty
      if vim.fn.line "$" == 1 and vim.fn.getline(1) == "" then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
          "local function hello(name)",
          '  print("Hello, " .. name)',
          "end",
          "",
          "local function goodbye(name)",
          '  print("Goodbye, " .. name)',
          "end",
          "",
          "local M = {}",
          "",
          "function M.greet()",
          '  hello("World")',
          "end",
          "",
          "function M.farewell()",
          '  goodbye("World")',
          "end",
          "",
          "return M",
        })
      end

      print("Test file loaded (filetype: " .. vim.bo.filetype .. "). Try :Telescope treesitter")
    end, 100)
  end,
})

-- Key mapping for easy testing
vim.keymap.set("n", "<leader>tt", "<cmd>Telescope treesitter<cr>", { desc = "Telescope Treesitter" })

print "Minimal config loaded. Press <leader>tt or run :Telescope treesitter to test"
