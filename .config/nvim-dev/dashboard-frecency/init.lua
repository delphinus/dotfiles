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
    opts = { debug = true },
    dependencies = { "nvim-lua/plenary.nvim" },
  },
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

local function make_callback(event)
  return function()
    require("lazy.stats").track(event)
  end
end

vim.iter({ "BufEnter", "BufWinEnter", "UIEnter", "VimEnter" }):each(function(event)
  vim.api.nvim_create_autocmd(event, { callback = make_callback(event) })
end)

do
  local event = "DashboardLoaded"
  vim.api.nvim_create_autocmd("User", { pattern = event, callback = make_callback(event) })
end
