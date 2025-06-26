vim.cmd [[echo "hoge2"]]

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

require("lazy").setup {
  {
    "folke/snacks.nvim",
    init = function()
      require("snacks").setup {
        notifier = { enabled = true },
      }
      vim.notify = Snacks.notifier.notify
    end,
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    init = function()
      -- load the session for the current directory
      vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end)
      -- select a session to load
      vim.keymap.set("n", "<leader>qS", function() require("persistence").select() end)
      -- load the last session
      vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end)
      -- stop Persistence => session won't be saved on exit
      vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end)
    end,
    opts = {},
  },
}
-- :restart , \ql
