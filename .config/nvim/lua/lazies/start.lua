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
    tag = "v3.0.1",
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

      palette "smoothcursor" {
        nord = function(colors)
          api.set_hl(0, "SmoothCursor", { fg = colors.white })
          api.set_hl(0, "SmoothCursorGreen", { fg = colors.green })
        end,
      }

      api.create_autocmd("ModeChanged", {
        desc = "Change signs for SmoothCursor according to modes",
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

  non_lazy {
    "folke/tokyonight.nvim",
    opts = {
      on_colors = function(colors)
        require("core.utils.palette.tokyonight").set(colors)
      end,
    },
  },

  non_lazy {
    "Bekaboo/dropbar.nvim",
    init = function()
      vim.keymap.set("n", "<A-d>", function()
        require("dropbar.api").pick()
      end)
    end,
    opts = {
      -- Use the default of vim-easymotion
      bar = { pick = { pivots = "asdghklqwertyuiopzxcvbnmfj;" } },
      menu = {
        keymaps = {
          ["<Esc>"] = function()
            local menu = require("dropbar.api").get_current_dropbar_menu()
            if menu then
              menu:close(true)
            end
          end,
        },
      },
      general = {
        ---@type boolean|fun(buf: integer, win: integer): boolean
        enable = function(buf, win)
          local buf_name = api.buf_get_name(buf)
          return not vim.api.nvim_win_get_config(win).zindex
            and vim.bo[buf].buftype == ""
            and buf_name ~= ""
            and not buf_name:match "^octo://"
            and not vim.wo[win].diff
        end,
      },
      icons = {
        ui = {
          bar = {
            separator = "",
          },
          menu = {
            separator = "",
            indicator = "",
          },
        },
      },
      sources = {
        path = {
          ---@type string|fun(buf: integer): string
          relative_to = function(_)
            return uv.cwd() or ""
          end,
        },
      },
    },
  },
}
