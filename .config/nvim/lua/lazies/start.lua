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
        disabled_filetypes = { "help", "TelescopePrompt", "man", "qf" },
      }

      palette "smoothcursor" {
        nord = function(colors)
          api.set_hl(0, "SmoothCursor", { fg = colors.white })
          api.set_hl(0, "SmoothCursorGreen", { fg = colors.green })
        end,
        sweetie = function(colors)
          api.set_hl(0, "SmoothCursor", { fg = colors.white })
          api.set_hl(0, "SmoothCursorGreen", { fg = colors.green })
        end,
      }

      local group = api.create_augroup("smooth-cursor-autocmds", {})

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

        local wininfo = " " .. vim.api.nvim_win_get_number(props.win)

        if props.focused and vim.api.nvim_win_get_cursor(props.win)[1] == 1 then
          return { { wininfo, group = "DevIconWindows" } }
        end

        local filename = vim.api.nvim_buf_get_name(props.buf)
        local devicons = require "nvim-web-devicons"
        local ft_icon, ft_color = devicons.get_icon_color(filename)
        if filename == "" then
          filename = "[No Name]"
        else
          filename = vim.fs.basename(filename)
        end

        return {
          { get_diagnostic_label() },
          { get_git_diff() },
          { (ft_icon or "") .. " ", guifg = ft_color, guibg = "none" },
          { filename .. " ", gui = vim.bo[props.buf].modified and "bold,italic" or "bold" },
          { "┊ " .. wininfo, group = "DevIconWindows" },
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
    -- "uga-rosa/ccc.nvim",
    "delphinus/ccc.nvim",
    branch = "feat/nvim-0.10-colors",
    config = function()
      local ccc = require "ccc"
      ccc.setup {
        highlight_mode = "virtual",
        highlighter = { auto_enable = true },
        -- virtual_symbol = "󰝤", -- 0xF0764
        virtual_symbol = "󰺠", -- 0xF0EA0
        pickers = {
          ccc.picker.defaults,
          ccc.picker.hex,
          ccc.picker.custom_entries(vim.iter(require "core.utils.palette.sweetie"):fold({}, function(a, k, v)
            if type(v) == "string" then
              a[k] = v
            end
            return a
          end)),
        },
      }
    end,
  },

  non_lazy {
    -- "Isrothy/neominimap.nvim",
    "delphinus/neominimap.nvim",
    branch = "fix/border",
    init = function()
      vim.opt.wrap = false -- Recommended
      vim.opt.sidescrolloff = 36 -- It's recommended to set a large value
      vim.g.neominimap = {
        auto_enable = true,
        exclude_filetypes = { "help", "vfiler" },
        margin = { top = 1 },
        window_border = "rounded",
      }

      vim.keymap.set("n", "<C-w>o", function()
        local window = require "neominimap.window"
        local winid = vim.api.nvim_get_current_win()
        vim
          .iter(vim.api.nvim_list_wins())
          :filter(function(w)
            return w ~= winid and w ~= window.get_minimap_winid(winid)
          end)
          :each(function(w)
            vim.api.nvim_win_close(w, false)
          end)
      end, { desc = "Overwrite default mapping for neominimap.nvim" })

      palette "neominimap" {
        sweetie = function(colors)
          vim.api.nvim_set_hl(0, "NeominimapCursorLine", { bg = colors.violet })
        end,
      }
    end,
  },

  non_lazy {
    "nvim-telescope/telescope-frecency.nvim",
    main = "frecency",
    ---@type FrecencyOpts
    opts = {
      debug = not not vim.env.DEBUG_FRECENCY,
      db_safe_mode = false,
      hide_current_buffer = true,
      scoring_function = function(recency, fzy_score)
        local score = (100 / (recency == 0 and 1 or recency)) - 1 / fzy_score
        return score == -1 and -1.00001 or score
      end,
      show_scores = true,
      show_filter_column = { "LSP", "CWD", "VIM" },
      workspaces = {
        VIM = vim.env.VIMRUNTIME,
      },
      ignore_patterns = { "*.git/*", "*/tmp/*", "term://*", "*/tmux-fingers/alphabets*" },
    },
  },
}
