local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

require("lazy").setup {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      "MunifTanjim/nui.nvim",
      -- { "rcarriga/nvim-notify", opts = { render = "compact" } },
    },
  },
  {
    "folke/snacks.nvim",
    init = function()
      require("snacks").setup {
        notifier = { enabled = true },
      }
      vim.notify = Snacks.notifier.notify
    end,
  },
}
