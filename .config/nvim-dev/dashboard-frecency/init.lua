-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  {
    "nvim-telescope/telescope-frecency.nvim",
    commit = "344e01f",
    main = "frecency",
    opts = { debug = true },
  },
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "nvim-telescope/telescope.nvim", cmd = { "Telescope" } },
  {
    "delphinus/dashboard-nvim",
    branch = "feat/mru-list-fn",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = { "VimEnter" },
    opts = {
      theme = "hyper",
      config = {
        mru = {
          list_fn = function()
            return require("frecency").query { limit = 20 }
          end,
        },
      },
    },
  },
}

vim.api.nvim_create_autocmd("User", {
  pattern = "DashboardLoaded",
  callback = function()
    require("lazy.stats").track "DashboardLoaded"
  end,
})
