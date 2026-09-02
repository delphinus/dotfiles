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
    init = function()
      -- "[C" / "]C" は "[y" / "]y" (string encode/decode) の別名なので、
      -- multicursor の |[C| |]C| (前/次のカーソルへジャンプ) に譲る。
      vim.g.nremap = { ["[C"] = "", ["]C"] = "" }
      vim.g.xremap = { ["[C"] = "", ["]C"] = "" }
    end,
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
    -- version = "*",
    -- TODO: trying plenary removal locally (PR #343). Revert when done.
    branch = "switch-to-neoplen",
    ---@module 'frecency'
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
        "<Cmd>Gitsigns setloclist<CR>",
        desc = "gitsigns.setloclist",
      },
      {
        -- "gQ" は multicursor の復元に取られたので "g<C-q>" へ。
        "g<C-q>",
        "<Cmd>Gitsigns setqflist all<CR>",
        desc = 'gitsigns.setqflist "all"',
      },
      {
        "g?",
        "<Cmd>Gitsigns preview_hunk<CR>",
        desc = "gitsigns.preview_hunk",
      },
    },
    init = function()
      local tokyonight_gitsigns = function(colors)
        -- tokyonight already covers GitSignsAdd/Change/Delete; only fill the rest.
        vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = colors.brighter_black })
        vim.api.nvim_set_hl(0, "GitSignsAddInline", { bg = colors.bg_green })
        vim.api.nvim_set_hl(0, "GitSignsChangeInline", { bg = colors.bg_yellow })
        vim.api.nvim_set_hl(0, "GitSignsDeleteInline", { bg = colors.bg_red })
        vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = colors.magenta })
      end
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
        ["tokyonight-storm"] = tokyonight_gitsigns,
        ["tokyonight-day"] = tokyonight_gitsigns,
      }
    end,
    ---@type Gitsigns.Config
    opts = {
      debug_mode = true,
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
      current_line_blame_opts = { delay = 500 },
      -- word_diff = true,
      on_attach = function(bufnr)
        local basename = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
        vim.notify("attaching Gitsigns: " .. basename)
      end,
    },
  },

  non_lazy { "delphinus/manage-help-tags.nvim", opts = {} },

  non_lazy {
    "yuki-yano/fuzzy-motion.vim",
    keys = { { "<Leader>s", "<Cmd>FuzzyMotion<CR>", mode = { "n", "x" } } },
    init = function()
      vim.g.fuzzy_motion_labels = vim.split("HJKLASDFGYUIOPQWERTNMZXCVB", "")
      vim.g.fuzzy_motion_matchers = "kensaku,fzf"

      local tokyonight_fuzzy_motion = function(colors)
        vim.api.nvim_set_hl(0, "FuzzyMotionShade", { fg = colors.gray })
        vim.api.nvim_set_hl(0, "FuzzyMotionChar", { fg = colors.red })
        vim.api.nvim_set_hl(0, "FuzzyMotionSubChar", { fg = colors.yellow })
        vim.api.nvim_set_hl(0, "FuzzyMotionMatch", { fg = colors.cyan })
      end
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
        ["tokyonight-storm"] = tokyonight_fuzzy_motion,
        ["tokyonight-day"] = tokyonight_fuzzy_motion,
      }
    end,
  },

  non_lazy {
    "delphinus/ghsigns.nvim",
    dependencies = {
      {
        "delphinus/md-render.nvim",
        version = "*",
        dependencies = { "delphinus/budoux.lua" },
        cmd = { "MdRender" },
        keys = {
          { "<M-P>", "<Plug>(md-render-preview)", desc = "Markdown preview (toggle)" },
          { "<M-T>", "<Plug>(md-render-preview-tab)", desc = "Markdown preview (tab)" },
          { "<M-D>", "<Plug>(md-render-demo)", desc = "Markdown render demo" },
          { "<M-S>", "<Cmd>vert MdRenderSplit<CR>", desc = "Open Markdown Preview" },
        },
        init = function()
          palette "sweetie" {
            nord = function(_)
              vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = "#88C0D0", bold = true })
              vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = "#A3BE8C", bold = true })
              vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { fg = "#EBCB8B", bold = true })
              vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { fg = "#D08770", bold = true })
              vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", { fg = "#B48EAD", bold = true })
              vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", { fg = "#ECEFF4", bold = true })
            end,
            sweetie = function(colors)
              vim.api.nvim_set_hl(0, "RenderMarkdownCode", { link = "CursorLine" })
              if colors.is_dark then
                vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = colors.blue, bg = "#303948", bold = true })
                vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = colors.green, bg = "#2b3324", bold = true })
                vim.api.nvim_set_hl(
                  0,
                  "@markup.heading.3.markdown",
                  { fg = colors.yellow, bg = "#3e3924", bold = true }
                )
                vim.api.nvim_set_hl(
                  0,
                  "@markup.heading.4.markdown",
                  { fg = colors.orange, bg = "#3e332a", bold = true }
                )
                vim.api.nvim_set_hl(
                  0,
                  "@markup.heading.5.markdown",
                  { fg = colors.magenta, bg = "#37223e", bold = true }
                )
                vim.api.nvim_set_hl(
                  0,
                  "@markup.heading.6.markdown",
                  { fg = colors.violet, bg = "#261C39", bold = true }
                )
              else
                vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = "#194064", bg = "#bee0ff", bold = true })
                vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = "#255517", bg = "#d1ffc3", bold = true })
                vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { fg = "#695c18", bg = "#fff3b9", bold = true })
                vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { fg = "#834e20", bg = "#e2d5c9", bold = true })
                vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", { fg = "#751c5e", bg = "#e2cbdc", bold = true })
                vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", { fg = "#54307c", bg = "#c4a9e2", bold = true })
              end
            end,
          }
        end,
        config = function()
          -- Override MdRenderShadowCursor with a muted plum bg so the
          -- unfocused side's matching line is visible without competing
          -- with the focused side's CursorLine. Re-apply on ColorScheme
          -- so theme reloads don't drop it.
          local function apply()
            vim.api.nvim_set_hl(0, "MdRenderShadowCursor", { bg = "#4a3a55" })
          end
          apply()
          vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("md_render_shadow_override", { clear = true }),
            callback = apply,
          })
        end,
      },
    },
    version = "*",
    opts = {},
  },

  non_lazy {
    "rachartier/tiny-cmdline.nvim",
    init = function()
      vim.o.cmdheight = 0
      require("vim._core.ui2").enable {}
    end,
    config = function()
      local tc = require "tiny-cmdline"
      tc.setup {
        on_reposition = vim.env.CMP and nil or tc.adapters.blink,
      }
    end,
  },

  non_lazy {
    "zaakiy/line-justice.nvim",
    dependencies = { "luukvbaal/statuscol.nvim" },
    config = function()
      local lj = require "line-justice"
      lj.setup()

      local builtin = require "statuscol.builtin"
      require("statuscol").setup {
        relculright = true,
        segments = {
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          { sign = { namespace = { "gitsigns" }, maxwidth = 1, colwidth = 1, auto = true }, click = "v:lua.ScSa" },
          { sign = { namespace = { "diagnostic/signs" }, maxwidth = 2, auto = true }, click = "v:lua.ScSa" },
          { sign = { name = { ".*" }, maxwidth = 2, colwidth = 1, auto = true, wrap = true }, click = "v:lua.ScSa" },
          { text = { lj.segment }, click = "v:lua.ScLa" },
        },
      }
    end,
  },
}
