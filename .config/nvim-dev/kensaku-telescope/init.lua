-- Dev env for obsidian-kensaku.nvim + telescope.nvim integration test.
-- Usage:
--   NVIM_APPNAME=nvim-dev/kensaku-telescope nvim
--
-- Keymaps:
--   <Leader>oq  :Obsidian quick_kensaku   (live filename search)
--   <Leader>os  :Obsidian kensaku         (live grep)
--   <Leader>oS  :Obsidian kensaku sabu    (one-shot grep with seed query)
--
-- Plugins are loaded from the main nvim's lazy dir via `dir = ...` to share
-- the already-cloned working copies (so local edits are visible immediately).

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local MAIN_LAZY = vim.env.HOME .. "/.local/share/nvim/lazy"
local VAULT = vim.env.HOME .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes"

require("lazy").setup {
  {
    "folke/tokyonight.nvim",
    dir = MAIN_LAZY .. "/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "nvim-telescope/telescope.nvim",
    dir = MAIN_LAZY .. "/telescope.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", dir = MAIN_LAZY .. "/plenary.nvim" },
    },
    opts = {},
  },
  {
    "fdschmidt93/telescope-egrepify.nvim",
    dir = MAIN_LAZY .. "/telescope-egrepify.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
  },
  {
    "delphinus/luamigemo",
    dir = MAIN_LAZY .. "/luamigemo",
  },
  {
    "delphinus/obsidian-kensaku.nvim",
    dir = MAIN_LAZY .. "/obsidian-kensaku.nvim",
    dependencies = { "delphinus/luamigemo" },
  },
  {
    "obsidian-nvim/obsidian.nvim",
    dir = MAIN_LAZY .. "/obsidian.nvim",
    ft = "markdown",
    cmd = { "Obsidian" },
    dependencies = { "delphinus/obsidian-kensaku.nvim" },
    opts = {
      legacy_commands = false,
      workspaces = { { name = "default", path = VAULT } },
      picker = { name = "telescope.nvim" },
      callbacks = {
        post_setup = function()
          require("obsidian-kensaku").setup { picker = "egrepify" }
        end,
      },
    },
  },
}

vim.cmd.colorscheme "tokyonight"

vim.keymap.set("n", "<Leader>oq", "<Cmd>Obsidian quick_kensaku<CR>", { desc = "Kensaku: live filename" })
vim.keymap.set("n", "<Leader>os", "<Cmd>Obsidian kensaku<CR>", { desc = "Kensaku: live grep" })
vim.keymap.set("n", "<Leader>oS", "<Cmd>Obsidian kensaku sabu<CR>", { desc = "Kensaku: one-shot grep 'sabu'" })

-- Open the vault root so :Obsidian commands have context immediately.
vim.schedule(function()
  vim.cmd.edit(VAULT)
end)
