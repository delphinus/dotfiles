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

      local group = vim.api.nvim_create_augroup("GitSignsRepoBase", {})
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = { "GitSignsUpdate" },
        callback = function(args)
          local actions = require "gitsigns.actions"
          local async = require "gitsigns.async"
          local cache = require("gitsigns.cache").cache

          local data = args.data
          if not data then
            return
          end
          local bufnr = args.data.buffer
          local status = vim.b[bufnr].gitsigns_status_dict
          local bcache = cache[bufnr]
          if not bcache or not status then
            return
          end
          local root = status.root
          local head = status.head
          if head == "HEAD" then
            return
          end

          ---@param pr { baseRefName: string, number: integer }
          local function change_pr(pr)
            if bcache.git_obj.revision == pr.baseRefName then
              return
            end
            vim.schedule(function()
              vim.api.nvim_buf_call(bufnr, function()
                vim.b.gh_pr = pr
                actions.change_base(pr.baseRefName, nil, function(err)
                  if err then
                    vim.notify("cannot change_base: " .. err, vim.log.levels.WARN)
                  end
                end)
              end)
            end)
          end

          local pr = vim.tbl_get(vim.g, "gh_pr_cache", root, head)
          if pr then
            change_pr(pr)
            return
          end

          local function set_pcache(pr_obj)
            vim.g.gh_pr_cache = vim.tbl_deep_extend("force", vim.g.gh_pr_cache or {}, { [root] = { [head] = pr_obj } })
          end

          async
            .run(function()
              local asystem = async.wrap(3, vim.system)
              ---@type vim.SystemCompleted
              ---@diagnostic disable-next-line: assign-type-mismatch
              local obj = asystem { "gh", "pr", "view", "--json", "baseRefName,number" }
              if obj.code ~= 0 then
                set_pcache {}
                ---@diagnostic disable-next-line: missing-return-value
                return
              end
              ---@type { baseRefName: string, number: integer }
              local pr_obj = vim.json.decode(obj.stdout)
              set_pcache(pr_obj)
              ---@diagnostic disable-next-line: missing-return-value, missing-return
              change_pr(pr_obj)
            end)
            :raise_on_error()
        end,
      })
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
      current_line_blame_opts = {
        delay = 10,
      },
      word_diff = true,
      on_attach = function(bufnr)
        local basename = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
        vim.notify("attaching Gitsigns: " .. basename)
      end,
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
