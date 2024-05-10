---@diagnostic disable: missing-fields
local lazy_require = require "lazy_require"
local palette = require "core.utils.palette"

local function non_lazy(plugin)
  plugin.lazy = false
  return plugin
end

return {
  { "delphinus/f_meta.nvim" },
  { "delphinus/lazy_require.nvim" },
  --{ "nvim-lua/plenary.nvim" },
  { "delphinus/plenary.nvim", branch = "feat/types" },

  non_lazy {
    "vim-denops/denops.vim",
    init = function()
      vim.g["denops#server#deno_args"] = { "-q", "--no-lock", "--unstable-kv", "-A" }
    end,
  },

  non_lazy {
    "delphinus/cellwidths.nvim",
    tag = "v3.2.2",
    build = ":CellWidthsRemove",
    config = function()
      --[[
      local function measure(name, f)
        local s = os.clock()
        f()
        vim.notify(("%s took %f ms"):format(name, (os.clock() - s) * 1000))
      end
      ]]

      vim.opt.listchars = {
        tab = "▓░",
        trail = "↔",
        eol = "⏎",
        extends = "‥",
        precedes = "←",
        nbsp = "␣",
      }
      vim.opt.fillchars = {
        diff = "░",
        eob = "‣",
        fold = "░",
        foldopen = "▾",
        foldsep = "│",
        foldclose = "▸",
      }
      require("cellwidths").setup {
        name = "user/custom",
        --log_level = "DEBUG",
        ---@param cw cellwidths
        fallback = function(cw)
          cw.load "sfmono_square"
          cw.add { 0xf0000, 0x10ffff, 2 }
          return cw
        end,
      }
    end,
  },

  {
    "delphinus/nord-nvim",
    build = lazy_require("nord").update {
      italic = true,
      uniform_status_lines = true,
      uniform_diff_background = true,
      cursor_line_number_background = true,
      language_specific_highlights = false,
    },
    config = function()
      palette "nord" {
        nord = function(colors)
          api.set_hl(0, "Comment", { fg = colors.comment, italic = true })
          api.set_hl(0, "Delimiter", { fg = colors.nord9 })
          api.set_hl(0, "PmenuSel", { blend = 0 })
          api.set_hl(0, "LspInlayHint", { fg = colors.nord3_bright, italic = true })
          api.set_hl(0, "Identifier", { fg = colors.blue, italic = true })
          api.set_hl(0, "Special", { fg = "#8fbcbb", bold = true })
          api.set_hl(0, "typescriptIdentifierName", { fg = "#ebcb8b", italic = true })
          api.set_hl(0, "@lsp.type.string.terraform", { link = "String" })
          api.set_hl(0, "@lsp.type.enumMember.terraform", { link = "String" })
          api.set_hl(0, "@markup.heading.1.markdown", { fg = "#88C0D0", bold = true })
          api.set_hl(0, "@markup.heading.2.markdown", { fg = "#A3BE8C", bold = true })
          api.set_hl(0, "@markup.heading.3.markdown", { fg = "#EBCB8B", bold = true })
          api.set_hl(0, "@markup.heading.4.markdown", { fg = "#D08770", bold = true })
          api.set_hl(0, "@markup.heading.5.markdown", { fg = "#B48EAD", bold = true })
          api.set_hl(0, "@markup.heading.6.markdown", { fg = "#ECEFF4", bold = true })
        end,
      }
    end,
  },

  {
    "rhysd/committia.vim",
    ft = { "gitcommit" },
    init = function()
      vim.g.committia_hooks = {
        ---@class CommittiaInfo
        ---@field vcs string vcs type (e.g. 'git')
        ---@field edit_winnr integer winnr of edit window
        ---@field edit_bufnr integer bufnr of edit window
        ---@field diff_winnr integer winnr of diff window
        ---@field diff_bufnr integer bufnr of diff window
        ---@field status_winnr integer winnr of status window
        ---@field status_bufnr integer bufnr of status window

        ---@param info CommittiaInfo
        edit_open = function(info)
          api.create_autocmd({ "BufWinEnter" }, {
            once = true,
            pattern = { "COMMIT_EDITMSG", "MERGE_MSG" },
            callback = function()
              local winid = fn.win_getid(info.edit_winnr)
              -- HACK: move cursor to top left because it starts on the 2nd line for some reason.
              api.win_set_cursor(winid, { 1, 0 })
              local first_line = api.buf_get_lines(info.edit_bufnr, 0, 1, false)[1]
              if first_line == "" then
                vim.cmd.startinsert()
              end
            end,
          })
          vim.keymap.set("i", "<A-D>", [[<Plug>(committia-scroll-diff-down-half)]], { buffer = true })
          vim.keymap.set("i", "<A-U>", [[<Plug>(committia-scroll-diff-up-half)]], { buffer = true })
        end,
      }
    end,
    config = function()
      local bufname = vim.fs.basename(api.buf_get_name(0))
      if bufname == "COMMIT_EDITMSG" or bufname == "MERGE_MSG" then
        fn["committia#open"] "git"
      end
    end,
  },

  {
    "m00qek/baleia.nvim",
    cmd = { "BaleiaColorize", "BaleiaColorizeStartup" },
    config = function()
      local baleia
      api.create_user_command("BaleiaColorize", function()
        if not baleia then
          baleia = require("baleia").setup {}
        end
        baleia.once(api.get_current_buf())
      end, {})
      api.create_user_command("BaleiaColorizeStartup", function()
        api.create_autocmd("VimEnter", { command = "BaleiaColorize" })
      end, {})
    end,
  },
}
