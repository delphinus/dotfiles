load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()

require("lazy").setup {
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "nvimdev/dashboard-nvim",
    event = { "VimEnter" },
    opts = { theme = "hyper", config = { mru = {} } },
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
