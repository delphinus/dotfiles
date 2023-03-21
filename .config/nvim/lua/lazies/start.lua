local fn, _, api = require("core.utils").globals()
local palette = require "core.utils.palette"

local function non_lazy(plugin)
  plugin.lazy = false
  return plugin
end

return {
  non_lazy {
    "direnv/direnv.vim",
    config = function()
      vim.g.direnv_silent_load = 1
    end,
  },

  non_lazy {
    "tpope/vim-unimpaired",
    --"delphinus/vim-unimpaired",
    config = function()
      local km = vim.keymap
      km.set("n", "[w", [[<Cmd>colder<CR>]])
      km.set("n", "]w", [[<Cmd>cnewer<CR>]])
      km.set("n", "[O", [[<Cmd>lopen<CR>]])
      km.set("n", "]O", [[<Cmd>lclose<CR>]])
    end,
  },

  non_lazy { "vim-jp/vimdoc-ja" },

  non_lazy { "vim-scripts/HiColors" },

  non_lazy {
    "delphinus/cellwidths.nvim",
    tag = "v2.2.0",
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
        extends = "→",
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

  non_lazy { "delphinus/rtr.nvim", config = true },

  non_lazy { "delphinus/unimpaired.nvim", branch = "feature/first-implementation", dev = true },

  non_lazy { "vim-denops/denops.vim" },

  non_lazy {
    "gen740/SmoothCursor.nvim",
    config = function()
      require("smoothcursor").setup {
        cursor = "▶", -- cursor shape (need nerd font)
        texthl = "SmoothCursor", -- highlight group, default is { bg = nil, fg = "#FFD400" }
        type = "default", -- define cursor movement calculate function, "default" or "exp" (exponential).
        fancy = {
          enable = true, -- enable fancy mode
          head = { cursor = "▷", texthl = "SmoothCursor", linehl = nil },
          body = {
            { cursor = "●", texthl = "SmoothCursorGreen" },
            { cursor = "•", texthl = "SmoothCursorGreen" },
            { cursor = "·", texthl = "SmoothCursorGreen" },
          },
        },
        flyin_effect = nil, -- "bottom" or "top"
        disable_float_win = true, -- disable on float window
        disabled_filetypes = { "help", "TelescopePrompt" },
      }

      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("smoothcursor-color", {}),
        callback = palette.callback(function(colors)
          api.set_hl(0, "SmoothCursor", { fg = colors.white })
          api.set_hl(0, "SmoothCursorGreen", { fg = colors.green })
        end),
      })

      api.create_autocmd("ModeChanged", {
        callback = function()
          local colors = palette.colors
          local cursor = {
            n = { char = "▶", color = colors.cyan },
            i = { char = "▷", color = colors.white },
            v = { char = "═", color = colors.bright_cyan },
            V = { char = "║", color = colors.bright_cyan },
            [""] = { char = "╬", color = colors.bright_cyan },
            R = { char = "⟩", color = colors.yellow },
          }
          local m = cursor[fn.mode()] or cursor.n
          api.set_hl(0, "SmoothCursor", { fg = m.color })
          fn.sign_define("smoothcursor", { text = m.char })
        end,
      })
    end,
  },

  non_lazy { "luukvbaal/statuscol.nvim", opts = {} },
}
