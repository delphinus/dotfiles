-- Dev env for obsidian-kensaku.nvim + snacks.picker integration test.
-- Usage:
--   NVIM_APPNAME=nvim-dev/kensaku-snacks nvim
--
-- Keymaps:
--   <Leader>oq  :Obsidian quick_kensaku   (live filename search via snacks)
--   <Leader>os  :Obsidian kensaku         (live grep via snacks)
--   <Leader>oS  :Obsidian kensaku sabu    (one-shot grep with seed query)

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
    "folke/snacks.nvim",
    dir = MAIN_LAZY .. "/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
    },
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
    dependencies = { "delphinus/obsidian-kensaku.nvim", "folke/snacks.nvim" },
    opts = {
      legacy_commands = false,
      workspaces = { { name = "default", path = VAULT } },
      picker = { name = "snacks.picker" },
      callbacks = {
        post_setup = function()
          require("obsidian-kensaku").setup {}
        end,
      },
    },
  },
}

vim.cmd.colorscheme "tokyonight"

vim.keymap.set("n", "<Leader>oq", "<Cmd>Obsidian quick_kensaku<CR>", { desc = "Kensaku: live filename" })
vim.keymap.set("n", "<Leader>os", "<Cmd>Obsidian kensaku<CR>", { desc = "Kensaku: live grep" })
vim.keymap.set("n", "<Leader>oS", "<Cmd>Obsidian kensaku sabu<CR>", { desc = "Kensaku: one-shot grep 'sabu'" })

vim.schedule(function()
  vim.cmd.edit(VAULT)
end)
