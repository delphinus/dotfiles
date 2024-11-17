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
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "nvimdev/dashboard-nvim",
    event = { "VimEnter" },
    opts = { theme = "hyper", config = { mru = {} } },
  },
}

vim.iter({ "BufEnter", "BufWinEnter", "UIEnter", "VimEnter" }):each(function(e)
  local count = 0
  vim.api.nvim_create_autocmd(e, {
    callback = function()
      count = count + 1
      require("lazy.stats").track(("%s-%d"):format(e, count))
    end,
  })
end)
