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
    },
  },
}
