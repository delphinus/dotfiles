---@diagnostic disable: missing-fields
local fn, _, api = require("core.utils").globals()
local palette = require "core.utils.palette"
local lazy_require = require "lazy_require"

local function non_lazy(plugin)
  plugin.lazy = false
  return plugin
end

return {
  { "nvim-tree/nvim-web-devicons" },

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
    version = "*",
    ---@module 'rtr'
    ---@type rtr.Opts
    opts = {
      root_names = function(name, path)
        return name == ".git"
          or path == vim.env.VIMRUNTIME
          or path == vim.env.HOME .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes"
          or path == vim.env.HOME .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents"
      end,
      log_level = false,
    },
  },

  non_lazy {
    enabled = false,
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

  non_lazy { enabled = false, "luukvbaal/statuscol.nvim", opts = {} },

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
        elseif props.focused then
          filename = vim.fs.basename(filename)
        else
          local Path = require "plenary.path"
          local cwd = vim.fs.root(filename, ".git") --[[@as string]]
          filename = Path:new(filename):make_relative(cwd)
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
    enabled = false,
    "delphinus/bigfile.nvim",
    branch = "feat/autocmd",
  },

  non_lazy {
    "delphinus/auto_fmt.nvim",
    init = function()
      vim.api.nvim_create_autocmd("BufWinEnter", {
        group = vim.api.nvim_create_augroup("auto_fmt_on_bufwinenter", {}),
        callback = function(ev)
          -- NOTE: stylua and lua_ls conflict on formatting Lua files. So we
          -- use ALE for stylua.
          if vim.bo[ev.buf].filetype == "lua" then
            require("auto_fmt").off(ev.buf)
          end
        end,
      })
    end,
    ---@module 'auto_fmt'
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
        return c.name ~= "ts_ls"
      end,
      verbose = false,
    },
  },

  non_lazy {
    "nvim-telescope/telescope-frecency.nvim",
    version = "*",
    ---@module 'frecency'
    ---@type FrecencyOpts
    opts = {
      db_version = "v2",
      debug = not not vim.env.DEBUG_FRECENCY,
      debug_timer = require("core.utils.timer").track,
      db_safe_mode = false,
      enable_prompt_mappings = true,
      preceding = "opened",
      scoring_function = function(recency, fzy_score)
        local score = (100 / (recency == 0 and 1 or recency)) - 1 / fzy_score
        return score == -1 and -1.00001 or score
      end,
      show_scores = true,
      show_filter_column = { "LSP", "CWD", "VIM" },
      unregister_hidden = true,
      workspaces = {
        VIM = vim.env.VIMRUNTIME,
      },
      ignore_patterns = { "*.git/*", "/tmp/*", "/private/tmp/*", "term://*" },
      file_ignore_patterns = vim.split(vim.env.IGNORE_DIRS or "", ",", { trimempty = true }),
    },
  },

  -- NOTE: gitsigns cannot be used with lazy-loading.
  -- https://github.com/lewis6991/gitsigns.nvim/issues/1291
  non_lazy {
    "lewis6991/gitsigns.nvim",
    keys = {
      {
        "]c",
        function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            require("gitsigns").nav_hunk "next"
          end
        end,
      },
      {
        "[c",
        function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            require("gitsigns").nav_hunk "prev"
          end
        end,
      },
      {
        "gL",
        lazy_require("gitsigns").setloclist(),
        desc = "gitsigns.setloclist",
      },
      {
        "gQ",
        lazy_require("gitsigns").setqflist "all",
        desc = 'gitsigns.setqflist "all"',
      },
    },
    init = function()
      palette "gitsigns" {
        nord = function(colors)
          vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = colors.green })
          vim.api.nvim_set_hl(0, "GitSignsChange", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = colors.red })
          vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = colors.brighter_black })
          vim.api.nvim_set_hl(0, "GitSignsAddInline", { bg = colors.bg_green })
          vim.api.nvim_set_hl(0, "GitSignsChangeInline", { bg = colors.bg_yellow })
          vim.api.nvim_set_hl(0, "GitSignsDeleteInline", { bg = colors.bg_red })
          vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = colors.magenta })
        end,
      }
    end,
    opts = {
      signs = {
        add = {},
        change = {},
        delete = { text = "✗" },
        topdelete = { text = "↑" },
        changedelete = { text = "•" },
        untracked = { text = "⢸" },
      },
      numhl = true,
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 10,
      },
      word_diff = true,
    },
  },

  non_lazy { "delphinus/manage-help-tags.nvim", opts = {} },

  non_lazy {
    "yuki-yano/fuzzy-motion.vim",
    keys = { { "s", "<Cmd>FuzzyMotion<CR>", mode = { "n", "x" } } },
    init = function()
      vim.g.fuzzy_motion_labels = vim.split("HJKLASDFGYUIOPQWERTNMZXCVB", "")
      vim.g.fuzzy_motion_matchers = "kensaku,fzf"

      palette "fuzzy_motion" {
        nord = function(colors)
          vim.api.nvim_set_hl(0, "FuzzyMotionShade", { fg = colors.gray })
          vim.api.nvim_set_hl(0, "FuzzyMotionChar", { fg = colors.red })
          vim.api.nvim_set_hl(0, "FuzzyMotionSubChar", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "FuzzyMotionMatch", { fg = colors.cyan })
        end,
        sweetie = function(colors)
          vim.api.nvim_set_hl(0, "FuzzyMotionShade", { fg = colors.dark_grey })
          vim.api.nvim_set_hl(0, "FuzzyMotionChar", { fg = colors.red })
          vim.api.nvim_set_hl(0, "FuzzyMotionSubChar", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "FuzzyMotionMatch", { fg = colors.cyan })
        end,
      }
    end,
  },
}
