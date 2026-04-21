local utils = require "core.utils"
local lazy_require = require "lazy_require"

local use_cmp = not not vim.env.CMP

local skkeleton_keys = {
  { "<A-j>", "<Plug>(skkeleton-disable)", mode = { "i", "c", "l" } },
  { "<A-J>", "<Plug>(skkeleton-enable)", mode = { "i", "c", "l" } },
  { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l" } },
}
if use_cmp then
  table.insert(
    skkeleton_keys,
    { "<C-x><C-o>", lazy_require("cmp").complete(), mode = { "i" }, desc = "Complete by nvim-cmp" }
  )
end

return {
  { "uga-rosa/cmp-skkeleton", enabled = use_cmp, event = { "InsertEnter", "CmdlineEnter" } },
  { "Xantibody/blink-cmp-skkeleton", enabled = not use_cmp },

  {
    "willelz/skk-tutorial.vim",
    cmd = { "SKKTutorialStart" },
    dependencies = { "denops.vim", "skkeleton" },
    config = function()
      utils.load_denops_plugin "skk-tutorial.vim"
      vim.wait(1000, function()
        return not not vim.api.nvim_get_commands({}).SKKTutorialStart
      end)
    end,
  },

  {
    "vim-skk/skkeleton",
    lazy = false,
    keys = skkeleton_keys,
    dependencies = { "denops.vim" },

    config = function()
      if use_cmp then
        require("core.skkeleton_cmp").setup()
      else
        -- skkeleton#map sets a buffer-local <nowait> <CR> that shadows blink's
        -- global mapping. Re-override after enable to delegate to blink when
        -- its menu is visible.
        local group = vim.api.nvim_create_augroup("skkeleton_blink_cr", {})
        vim.api.nvim_create_autocmd("User", {
          group = group,
          pattern = "skkeleton-enable-post",
          callback = function()
            vim.keymap.set("i", "<CR>", function()
              local ok, blink = pcall(require, "blink.cmp")
              if ok and blink.is_visible() then
                blink.select_and_accept()
                return
              end
              vim.fn["skkeleton#handle"]("handleKey", { key = "<CR>" })
            end, { buffer = true, nowait = true, desc = "blink + skkeleton <CR>" })
          end,
        })
        vim.api.nvim_create_autocmd("User", {
          group = group,
          pattern = "skkeleton-disable-pre",
          callback = function()
            pcall(vim.keymap.del, "i", "<CR>", { buffer = true })
          end,
        })
      end

      vim.fn["skkeleton#config"] {
        userDictionary = vim.fs.normalize "~/Documents/skk-jisyo.utf8",
        eggLikeNewline = true,
        immediatelyCancel = false,
        registerConvertResult = true,
        sources = { "skk_server" }, -- use yaskkserv2
        skkServerResEnc = "utf-8",
        databasePath = vim.fn.stdpath "data" .. "/skkeleton.db",
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
}
