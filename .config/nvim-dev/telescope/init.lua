local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

require("lazy").setup {
  { "nvim-telescope/telescope-frecency.nvim", opts = {} },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      {
        "<leader>ff",
        mode = { "n" },
        ':Telescope frecency workspace=CWD path_display={"smart"} <CR>',
        {
          desc = "Telescope find files using frecency",
          silent = true,
        },
      },
    },
  },
}
