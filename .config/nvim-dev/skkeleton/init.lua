local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  load(vim.fn.system "curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua")()
end

require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  {
    "vim-skk/skkeleton",
    dependencies = {
      {
        "vim-denops/denops.vim",
        init = function()
          vim.g["denops#server#deno_args"] = { "-q", "--no-lock", "--unstable-kv", "-A" }
        end,
      },
      { "delphinus/skkeleton_indicator.nvim", opts = { fadeOutMs = 0 } },
    },
    lazy = false,
    keys = {
      -- Use these mappings in Karabiner-Elements
      { "<A-j>", "<Plug>(skkeleton-disable)", mode = { "i", "c", "l" } },
      { "<A-J>", "<Plug>(skkeleton-enable)", mode = { "i", "c", "l" } },
      { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l" } },
    },
    config = function()
      local function dic(name)
        return { "~/Library/Application Support/AquaSKK/" .. name, name:match "utf8" and "utf-8" or "euc-jp" }
      end

      vim.fn["skkeleton#config"] {
        globalDictionaries = {
          dic "SKK-JISYO.L",
          dic "SKK-JISYO.jinmei",
          --dic "SKK-JISYO.fullname",
          dic "SKK-JISYO.fullname.utf8",
          dic "SKK-JISYO.geo",
          dic "SKK-JISYO.propernoun",
          dic "SKK-JISYO.station",
          dic "SKK-JISYO.law",
          dic "SKK-JISYO.china_taiwan",
          dic "SKK-JISYO.assoc",
          dic "SKK-JISYO.zipcode",
          dic "SKK-JISYO.office.zipcode",
          dic "SKK-JISYO.JIS2",
          --dic "SKK-JISYO.JIS3_4",
          dic "SKK-JISYO.JIS3_4.utf8",
          --dic "SKK-JISYO.JIS2004",
          dic "SKK-JISYO.JIS2004.utf8",
          dic "SKK-JISYO.itaiji",
          --dic "SKK-JISYO.itaiji.JIS3_4",
          dic "SKK-JISYO.itaiji.JIS3_4.utf8",
          dic "SKK-JISYO.mazegaki",
          dic "SKK_JISYO.shikakugoma",
          dic "SKK-JISYO.emoji.utf8",
          dic "SKK-JISYO.emoji-ja.utf8",
          dic "SKK-JISYO.jawiki.utf8",
        },
        userDictionary = vim.fs.normalize "~/Documents/skk-jisyo.utf8",
        eggLikeNewline = true,
        immediatelyCancel = false,
        registerConvertResult = true,
        sources = { "deno_kv", "google_japanese_input" },
        databasePath = vim.fn.stdpath "data" .. "/skkeleton.db",
        -- markerHenkan = "󰇆",
        -- markerHenkanSelect = "󱨉",
        -- markerHenkan = "󰽤",
        -- markerHenkanSelect = "󰽢",
        -- markerHenkan = "󰜌",
        -- markerHenkanSelect = "󰜋",
        -- markerHenkan = "󰝣",
        -- markerHenkanSelect = "󰄮",
      }
      vim.fn["skkeleton#register_kanatable"]("rom", {
        ["("] = { "（", "" },
        [")"] = { "）", "" },
        ["z "] = { "　", "" },
        ["z1"] = { "①", "" },
        ["z2"] = { "②", "" },
        ["z3"] = { "③", "" },
        ["z4"] = { "④", "" },
        ["z5"] = { "⑤", "" },
        ["z6"] = { "⑥", "" },
        ["z7"] = { "⑦", "" },
        ["z8"] = { "⑧", "" },
        ["z9"] = { "⑨", "" },
        ["<s-q>"] = "henkanPoint",
      })
    end,
  },
}, { lazy = false })
