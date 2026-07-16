-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "kjuq/skkelua.nvim",
    config = function()
      require("skkelua").config {
        globalDictionaries = { "~/.skk/SKK-JISYO.L" },
        completion = {
          enabled = true,
          insertOnSelect = true, -- 候補にフォーカスした時点で本文へ挿入する
          deferOkuri = true, -- 送り仮名確定でも自動変換せず、第一候補を自動選択する
        },
        pureSpace = true, -- Space を変換に使わず「変換中なら確定 + 空白」にする
      }
      vim.keymap.set({ "i", "c" }, "<C-j>", "<Plug>(skkelua-toggle)")
    end,
  },
}, {
  -- Ensure treesitter markdown parser is installed
})
