---@diagnostic disable: missing-fields
local fn, _, api = require("core.utils").globals()
local palette = require "core.utils.palette"
local lazy_utils = require "core.utils.lazy"

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
        return c.name ~= "ts_ls" or c.name ~= "lua"
      end,
      verbose = false,
    },
  },

  non_lazy {
    "Isrothy/neominimap.nvim",
    init = function()
      vim.opt.wrap = false -- Recommended
      vim.opt.sidescrolloff = 36 -- It's recommended to set a large value
      ---@type Neominimap.UserConfig
      vim.g.neominimap = {
        auto_enable = true,
        exclude_filetypes = { "help", "vfiler", "dashboard", "markdown" },
        float = { margin = { top = 1 }, window_border = "none" },
        treesitter = { enabled = lazy_utils.has_plugin "nvim-treesitter" },
        git = { enabled = lazy_utils.has_plugin "gitsigns.nvim", mode = "line" },
        click = { enabled = true },
        search = { enabled = true },
        winopt = function(opt, _)
          opt.winblend = 30
        end,
      }

      vim.api.nvim_create_autocmd("CursorMoved", {
        group = vim.api.nvim_create_augroup("auto-toggle-neominimap", {}),
        callback = function(ev)
          local win = vim.api.nvim_get_current_win()
          local row = vim.api.nvim_win_get_cursor(win)[1] - 1
          local line = vim.api.nvim_buf_get_lines(ev.buf, row, row + 1, true)[1]
          local extmarks = vim.api.nvim_buf_get_extmarks(
            ev.buf,
            -1,
            { row, 0 },
            { row + 1, 0 },
            { details = true, type = "virt_text" }
          )
          local line_length = vim
            .iter(extmarks)
            :filter(function(extmark)
              return extmark[4].virt_text_pos == "inline"
            end)
            :fold(vim.api.nvim_strwidth(line), function(sum, extmark)
              return sum
                + vim.iter(extmark[4].virt_text):fold(0, function(len, text)
                  return len + vim.api.nvim_strwidth(text[1])
                end)
            end)
          local win_width = vim.api.nvim_win_get_width(win)
          local minimap_width = require("neominimap.config").float.minimap_width
          local num_sign_width = 6 -- TODO: calculate this
          if win_width - minimap_width - num_sign_width < line_length then
            require("neominimap").winOff { win }
          else
            require("neominimap").winOn { win }
          end
        end,
      })

      local function normal_wins()
        return vim.iter(vim.api.nvim_tabpage_list_wins(0)):filter(function(w)
          -- NOTE: This means the window is not float win.
          return vim.api.nvim_win_get_config(w).relative == ""
        end)
      end

      vim.keymap.set("n", "<C-w>o", function()
        local winid = vim.api.nvim_get_current_win()
        normal_wins():each(function(w)
          if w ~= winid then
            vim.api.nvim_win_close(w, false)
          end
        end)
      end, { desc = "Overwrite default mapping for neominimap.nvim" })

      ---@param clockwise boolean
      local function rotate_window(clockwise)
        return function()
          local winnr_to_id = normal_wins():fold({}, function(a, b)
            local winnr = vim.api.nvim_win_get_number(b)
            a[winnr] = b
            return a
          end)
          local current = vim.api.nvim_win_get_number(0)
          local winnr = (current + (clockwise and 1 or -1) - 1) % #winnr_to_id + 1
          vim.api.nvim_set_current_win(winnr_to_id[winnr])
        end
      end

      vim.keymap.set("n", "<C-w>w", rotate_window(true), { desc = "Overwrite default mapping for neominimap.nvim" })
      vim.keymap.set("n", "<C-w>W", rotate_window(false), { desc = "Overwrite default mapping for neominimap.nvim" })
      vim.keymap.set("n", "<C-w><C-w>", rotate_window(true), { desc = "Overwrite default mapping for neominimap.nvim" })

      palette "neominimap" {
        sweetie = function(colors)
          vim.api.nvim_set_hl(0, "NeominimapCursorLine", { bg = colors.violet })
        end,
      }
    end,
  },

  non_lazy {
    "nvim-telescope/telescope-frecency.nvim",
    version = "*",
    ---@type FrecencyOpts
    opts = {
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
      workspaces = {
        VIM = vim.env.VIMRUNTIME,
      },
      ignore_patterns = { "*.git/*", "*/tmp/*", "term://*" },
    },
  },

  {
    "folke/snacks.nvim",
    lazy = false,
    opts = function()
      Snacks.toggle.profiler():map "<Leader>pp"
      Snacks.toggle.profiler_highlights():map "<Leader>ph"
    end,
    keys = {
      {
        "<Leader>ps",
        function()
          Snacks.profiler.scratch()
        end,
        desc = "Profiler Scratch Buffer",
      },
    },
  },
}
