local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

require("lazy").setup {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "Telescope" },
    opts = {},
  },
  {
    "delphinus/rtbrowse.nvim",
    keys = {
      {
        "<Leader>gB",
        function()
          require("rtbrowse").browse()
        end,
        mode = { "n", "x", "o" },
      },
    },
  },
}
