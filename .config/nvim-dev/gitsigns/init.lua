local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

require("lazy").setup {
  {
    "lewis6991/gitsigns.nvim",
    event = { "FocusLost", "CursorHold" },
    lazy = true,
    opts = { current_line_blame = true },
  },
}
