local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

require("lazy.stats").cputime()

local function get_t()
  local ffi = require "ffi"
  local pnano = assert(ffi.new("nanotime[?]", 1))
  local CLOCK_MONOTONIC = jit.os == "OSX" and 6 or 1
  ffi.C.clock_gettime(CLOCK_MONOTONIC, pnano)
  return tonumber(pnano[0].tv_sec) * 1e3 + tonumber(pnano[0].tv_nsec) / 1e6
end

local start = get_t()

require("lazy").setup {
  {
    "nvimdev/dashboard-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = { "VimEnter" },
    opts = { theme = "hyper", config = { mru = {} } },
  },
}

vim.api.nvim_create_autocmd("User", {
  once = true,
  pattern = "DashboardLoaded",
  callback = function()
    if vim.env.LOGFILE then
      local finish = get_t()
      vim.fn.writefile({ tostring(finish - start) }, vim.env.LOGFILE, "a")
      vim.cmd.q()
    end
  end,
})
