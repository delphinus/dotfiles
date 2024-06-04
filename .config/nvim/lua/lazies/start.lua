---@diagnostic disable: missing-fields
local fn, _, api = require("core.utils").globals()
local palette = require "core.utils.palette"

local function non_lazy(plugin)
  plugin.lazy = false
  return plugin
end

return {
  non_lazy {
    enabled = not vim.env.LIGHT,
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
    "delphinus/rtr.nvim",
    opts = {
      root_names = function(name, dir)
        return name == ".git"
          or dir == vim.env.VIMRUNTIME
          or dir == vim.env.HOME .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents"
      end,
    },
  },

  non_lazy { "delphinus/unimpaired.nvim", branch = "feature/first-implementation", dev = true },

  non_lazy {
    enabled = not vim.env.LIGHT,
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
        disabled_filetypes = { "help", "TelescopePrompt", "man" },
      }

      palette "smoothcursor" {
        nord = function(colors)
          api.set_hl(0, "SmoothCursor", { fg = colors.white })
          api.set_hl(0, "SmoothCursorGreen", { fg = colors.green })
        end,
      }

      local group = api.create_augroup("smooth-cursor-autocmds", {})

      -- avoid chattering the cursor
      vim.opt.signcolumn = "yes"
      api.create_autocmd("TermOpen", {
        desc = "Disable signcolumn when a terminal starts",
        group = group,
        callback = function()
          vim.opt.signcolumn = "no"
        end,
      })
      api.create_autocmd("TermLeave", {
        desc = "Enable signcolumn when it leaves a terminal",
        group = group,
        callback = function()
          vim.opt.signcolumn = "yes"
        end,
      })

      api.create_autocmd("ModeChanged", {
        desc = "Change signs for SmoothCursor according to modes",
        group = group,
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

      api.create_autocmd("User", {
        desc = "Disable SmoothCursor.nvim in large files",
        pattern = "BigfileBufReadPost",
        group = group,
        callback = function(args)
          vim.api.nvim_buf_call(args.buf, function()
            require("smoothcursor.utils").smoothcursor_stop()
          end)
        end,
      })
    end,
  },

  non_lazy { enabled = not vim.env.LIGHT, "luukvbaal/statuscol.nvim", opts = {} },

  --[[ non_lazy {
    enabled = not vim.env.LIGHT,
    "folke/tokyonight.nvim",
    opts = {
      on_colors = function(colors)
        require("core.utils.palette.tokyonight").set(colors)
      end,
    },
  }, ]]

  -- non_lazy {
  --   "Bekaboo/dropbar.nvim",
  --   init = function()
  --     vim.keymap.set({ "n", "t" }, "<C-A-d>", function()
  --       require("dropbar.api").pick()
  --     end)
  --   end,
  --   opts = {
  --     -- Use the default of vim-easymotion
  --     bar = { pick = { pivots = "hjklasdfgyuiopqwertnmzxcvb" } },
  --     menu = {
  --       keymaps = {
  --         ["<Esc>"] = function()
  --           local menu = require("dropbar.api").get_current_dropbar_menu()
  --           if menu then
  --             menu:close(true)
  --           end
  --         end,
  --       },
  --     },
  --     general = {
  --       ---@type boolean|fun(buf: integer, win: integer): boolean
  --       enable = function(buf, win)
  --         local buf_name = api.buf_get_name(buf)
  --         return not vim.api.nvim_win_get_config(win).zindex
  --           and (vim.bo[buf].buftype == "" or vim.bo[buf].buftype == "terminal")
  --           and buf_name ~= ""
  --           and not buf_name:match "^octo://"
  --           and not vim.wo[win].diff
  --       end,
  --     },
  --     icons = {
  --       ui = {
  --         bar = {
  --           separator = "",
  --         },
  --         menu = {
  --           separator = "",
  --           indicator = "",
  --         },
  --       },
  --     },
  --     sources = {
  --       path = {
  --         ---@type string|fun(buf: integer): string
  --         relative_to = function(_)
  --           return uv.cwd() or ""
  --         end,
  --       },
  --       terminal = { icon = " " },
  --     },
  --   },
  -- },

  non_lazy {
    "b0o/incline.nvim",
    opts = {
      ---@param props { buf: integer, win: integer, focused: boolean }
      ---@return table
      render = function(props)
        local function get_git_diff()
          local signs = vim.b[props.buf].gitsigns_status_dict
          return signs
            and vim.iter({ removed = "↑", changed = "→", added = "↓" }):fold(
              {},
              ---@param result { [1]: string, group: string }[]
              ---@param name string
              ---@param icon string
              function(result, name, icon)
                if tonumber(signs[name]) and signs[name] > 0 then
                  if #result == 0 then
                    table.insert(result, { "┊ " })
                  end
                  table.insert(result, #result, { icon .. signs[name] .. " ", group = "Diff" .. name })
                end
                return result
              end
            )
        end

        local function get_diagnostic_label()
          return vim.iter({ error = "●", warn = "○", info = "■", hint = "□" }):fold(
            {},
            ---@param result { [1]: string, group: string }[]
            ---@param severity string
            ---@param icon string
            function(result, severity, icon)
              local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[severity:upper()] })
              if n > 0 then
                if #result == 0 then
                  table.insert(result, { "┊ " })
                end
                table.insert(result, #result, { icon .. n .. " ", group = "DiagnosticSign" .. severity })
              end
              return result
            end
          )
        end

        local Path = require "plenary.path"
        local filename = vim.api.nvim_buf_get_name(props.buf)
        local devicons = require "nvim-web-devicons"
        local ft_icon, ft_color = devicons.get_icon_color(filename)
        if filename == "" then
          filename = "[No Name]"
        elseif props.focused then
          local p = Path:new(filename)
          p:make_relative(assert(vim.uv.cwd()))
          filename = p:shorten()
        else
          filename = vim.fs.basename(filename)
        end

        return {
          { get_diagnostic_label() },
          { get_git_diff() },
          { (ft_icon or "") .. " ", guifg = ft_color, guibg = "none" },
          { filename .. " ", gui = vim.bo[props.buf].modified and "bold,italic" or "bold" },
          { "┊  " .. vim.api.nvim_win_get_number(props.win), group = "DevIconWindows" },
        }
      end,
    },
  },

  non_lazy { "git@github.com:delphinus/fiv.nvim", opts = { mapping = true } },

  non_lazy {
    -- "LunarVim/bigfile.nvim"
    "delphinus/bigfile.nvim",
    branch = "feat/autocmd",
  },

  non_lazy {
    "delphinus/auto_fmt.nvim",
    ---@type AutoFmtOptions
    opts = {
      filter = function(c)
        local ignore_paths = {
          "%/neovim$",
          "%/vim$",
          "%/vim%/src$",
        }
        local root_dir = c.config.root_dir
        if root_dir then
          for _, re in ipairs(ignore_paths) do
            local m = root_dir:match(re)
            if m then
              vim.notify("[auto_formatting] this project ignored: " .. m, vim.log.levels.DEBUG)
              return false
            end
          end
        end
        return c.name ~= "tsserver" or c.name ~= "lua"
      end,
      verbose = false,
    },
  },

  non_lazy { "tani/dmacro.nvim", opts = { dmacro_key = "<A-t>" } },

  non_lazy {
    enabled = false,
    "brenoprata10/nvim-highlight-colors",
    opts = {
      render = "virtual",
      -- virtual_symbol = "", -- 0xEBB4
      -- virtual_symbol = "", -- 0xF0C8
      -- virtual_symbol = "󰃚", -- 0xF00DA
      -- virtual_symbol = "󰄮", -- 0xF012E
      -- virtual_symbol = "󰄯", -- 0xF012F
      -- virtual_symbol = "󰋘", -- 0xF02D8
      -- virtual_symbol = "󰏃", -- 0xF03C3
      -- virtual_symbol = "󰑊", -- 0xF044A
      -- virtual_symbol = "󰓛", -- 0xF04DB
      -- virtual_symbol = "󰚍", -- 0xF068D
      -- virtual_symbol = "󰜋", -- 0xF070B
      virtual_symbol = "󰝤", -- 0xF0764
      -- virtual_symbol = "󰝬", -- 0xF076C
      -- virtual_symbol = "󰤨", -- 0xF0928
      -- virtual_symbol = "󰧞", -- 0xF09DE
      -- virtual_symbol = "󰨓", -- 0xF0A13
      -- virtual_symbol = "󰪯", -- 0xF0AAF
      -- virtual_symbol = "󰫈", -- 0xF0AC8
      -- virtual_symbol = "󰫍", -- 0xF0ACD
      -- virtual_symbol = "󰮊", -- 0xF0B8A
      -- virtual_symbol = "󰮥", -- 0xF0BA5
      -- virtual_symbol = "󰺠", -- 0xF0EA0
      -- virtual_symbol = "󰽢", -- 0xF0F62
      -- virtual_symbol = "󰺠", -- 0xF0EA0
      virtual_symbol_suffix = "",
      -- from here
      -- https://github.com/neovim/neovim/blob/50f6d364c661b88a1edc5ffc8e284d1c0ff70810/src/nvim/highlight_group.c#L2909-L2939
      custom_colors = {
        { label = "NvimDarkBlue", color = "#004c73" },
        { label = "NvimDarkCyan", color = "#007373" },
        { label = "NvimDarkGray1", color = "#07080d" },
        { label = "NvimDarkGray2", color = "#14161b" },
        { label = "NvimDarkGray3", color = "#2c2e33" },
        { label = "NvimDarkGray4", color = "#4f5258" },
        { label = "NvimDarkGreen", color = "#005523" },
        { label = "NvimDarkGrey1", color = "#07080d" },
        { label = "NvimDarkGrey2", color = "#14161b" },
        { label = "NvimDarkGrey3", color = "#2c2e33" },
        { label = "NvimDarkGrey4", color = "#4f5258" },
        { label = "NvimDarkMagenta", color = "#470045" },
        { label = "NvimDarkRed", color = "#590008" },
        { label = "NvimDarkYellow", color = "#6b5300" },
        { label = "NvimLightBlue", color = "#a6dbff" },
        { label = "NvimLightCyan", color = "#8cf8f7" },
        { label = "NvimLightGray1", color = "#eef1f8" },
        { label = "NvimLightGray2", color = "#e0e2ea" },
        { label = "NvimLightGray3", color = "#c4c6cd" },
        { label = "NvimLightGray4", color = "#9b9ea4" },
        { label = "NvimLightGreen", color = "#b3f6c0" },
        { label = "NvimLightGrey1", color = "#eef1f8" },
        { label = "NvimLightGrey2", color = "#e0e2ea" },
        { label = "NvimLightGrey3", color = "#c4c6cd" },
        { label = "NvimLightGrey4", color = "#9b9ea4" },
        { label = "NvimLightMagenta", color = "#ffcaff" },
        { label = "NvimLightRed", color = "#ffc0b9" },
        { label = "NvimLightYellow", color = "#fce094" },
      },
    },
  },

  non_lazy {
    "uga-rosa/ccc.nvim",
    config = function()
      local ccc = require "ccc"
      ccc.setup {
        highlight_mode = "virtual",
        highlighter = { auto_enable = true },
        -- virtual_symbol = "󰝤", -- 0xF0764
        virtual_symbol = "󰺠", -- 0xF0EA0
        pickers = {
          ccc.picker.hex,
          ccc.picker.custom_entries(require "core.utils.palette.nord"),
          ccc.picker.custom_entries {
            NvimDarkBlue = "#004c73",
            NvimDarkCyan = "#007373",
            NvimDarkGray1 = "#07080d",
            NvimDarkGray2 = "#14161b",
            NvimDarkGray3 = "#2c2e33",
            NvimDarkGray4 = "#4f5258",
            NvimDarkGreen = "#005523",
            NvimDarkGrey1 = "#07080d",
            NvimDarkGrey2 = "#14161b",
            NvimDarkGrey3 = "#2c2e33",
            NvimDarkGrey4 = "#4f5258",
            NvimDarkMagenta = "#470045",
            NvimDarkRed = "#590008",
            NvimDarkYellow = "#6b5300",
            NvimLightBlue = "#a6dbff",
            NvimLightCyan = "#8cf8f7",
            NvimLightGray1 = "#eef1f8",
            NvimLightGray2 = "#e0e2ea",
            NvimLightGray3 = "#c4c6cd",
            NvimLightGray4 = "#9b9ea4",
            NvimLightGreen = "#b3f6c0",
            NvimLightGrey1 = "#eef1f8",
            NvimLightGrey2 = "#e0e2ea",
            NvimLightGrey3 = "#c4c6cd",
            NvimLightGrey4 = "#9b9ea4",
            NvimLightMagenta = "#ffcaff",
            NvimLightRed = "#ffc0b9",
            NvimLightYellow = "#fce094",
          },
        },
      }
    end,
  },

  non_lazy {
    "delphinus/skkeleton_indicator.nvim",

    init = function()
      palette "skkeleton_indicator" {
        nord = function(colors)
          api.set_hl(0, "SkkeletonIndicatorEiji", { fg = colors.cyan, bg = colors.dark_black, bold = true })
          api.set_hl(0, "SkkeletonIndicatorHira", { fg = colors.dark_black, bg = colors.green, bold = true })
          api.set_hl(0, "SkkeletonIndicatorKata", { fg = colors.dark_black, bg = colors.yellow, bold = true })
          api.set_hl(0, "SkkeletonIndicatorHankata", { fg = colors.dark_black, bg = colors.magenta, bold = true })
          api.set_hl(0, "SkkeletonIndicatorZenkaku", { fg = colors.dark_black, bg = colors.cyan, bold = true })
          api.set_hl(0, "SkkeletonIndicatorAbbrev", { fg = colors.white, bg = colors.red, bold = true })
        end,
      }
    end,

    ---@type SkkeletonIndicatorOpts
    opts = { fadeOutMs = 0 },
  },
}
