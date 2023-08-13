local fn, uv, api = require("core.utils").globals()
local palette = require "core.utils.palette"

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    -- set modules in detail because telescope-frecency is needed before
    -- telescope itself to save its history in opening buffers.
    dependencies = {
      { "delphinus/telescope-memo.nvim" },
      { "kyazdani42/nvim-web-devicons" },

      {
        "folke/todo-comments.nvim",
        event = { "BufRead", "FocusLost", "CursorHold" },
        opts = {
          keywords = {
            FIX = { icon = "", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
            TODO = { icon = "", color = "info" },
            HACK = { icon = "", color = "warning" },
            WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
            PERF = { icon = "󰅒", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
            NOTE = { icon = "󰍨", color = "hint", alt = { "INFO" } },
            TEST = { icon = "", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
          },
        },
      },

      { "nvim-lua/popup.nvim" },
      { "nvim-telescope/telescope-file-browser.nvim" },
      { "nvim-telescope/telescope-frecency.nvim", dependencies = { "kkharji/sqlite.lua" } },
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "nvim-telescope/telescope-ghq.nvim" },
      { "nvim-telescope/telescope-github.nvim" },
      { "nvim-telescope/telescope-node-modules.nvim" },
      { "nvim-telescope/telescope-smart-history.nvim", dependencies = { "tami5/sql.nvim" } },
      { "nvim-telescope/telescope-symbols.nvim" },
      { "nvim-telescope/telescope-z.nvim" },
      { "stevearc/dressing.nvim" },
      {
        "gbprod/yanky.nvim",
        keys = {
          { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" } },
          { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" } },
          { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" } },
          { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" } },
          { "<A-n>", "<Plug>(YankyCycleForward)" },
          { "<A-p>", "<Plug>(YankyCycleBackward)" },
          { "<A-y>", "<Cmd>YankyRingHistory" },
        },
        dependencies = { "kkharji/sqlite.lua" },
        opts = { ring = { storage = "sqlite" } },
      },
      { "fcying/telescope-ctags-outline.nvim" },
    },

    init = function()
      local keymap = vim.keymap

      palette "telescope" {
        nord = function(colors)
          api.set_hl(0, "TelescopeMatching", { fg = colors.magenta })
          api.set_hl(0, "TelescopePreviewBorder", { fg = colors.green })
          api.set_hl(0, "TelescopePromptBorder", { fg = colors.cyan })
          api.set_hl(0, "TelescopeResultsBorder", { fg = colors.blue })
          api.set_hl(0, "TelescopeSelection", { fg = colors.blue })
          api.set_hl(0, "TelescopeSelectionCaret", { fg = colors.blue })

          api.set_hl(0, "TelescopeBufferLoaded", { fg = colors.magenta })
          api.set_hl(0, "TelescopePathSeparator", { fg = colors.brighter_black })
          api.set_hl(0, "TelescopeFrecencyScores", { fg = colors.yellow })
          api.set_hl(0, "TelescopeQueryFilter", { fg = colors.bright_cyan })
        end,
      }

      local function builtin(name)
        return function(opt)
          return function()
            return require("telescope.builtin")[name](opt or {})
          end
        end
      end

      local function extensions(name, prop)
        return function(opt)
          return function()
            local telescope = require "telescope"
            telescope.load_extension(name)
            return telescope.extensions[name][prop](opt or {})
          end
        end
      end

      local function frecency(opts)
        opts.path_display = require("core.telescope.frecency").path_display
        return extensions("frecency", "frecency")(opts)
      end

      -- Lines
      keymap.set("n", "#", builtin "current_buffer_fuzzy_find" {}, { desc = "Telescope current_buffer_fuzzy_find" })

      -- Files
      keymap.set("n", "<Leader>fB", builtin "buffers" {}, { desc = "Telescope buffers" })
      keymap.set("n", "<Leader>fb", function()
        local cwd = fn.expand "%:h"
        extensions("file_browser", "file_browser") { cwd = cwd ~= "" and cwd or nil }()
      end, { desc = "Telescope file_browser" })
      keymap.set("n", "<Leader>ff", frecency { workspace = "CWD" }, { desc = "Telescope frecency on CWD" })

      local function input_grep_string(prompt, func)
        return function()
          vim.ui.input({ prompt = prompt }, function(input)
            if input then
              func { only_sort_text = true, search = input }()
            else
              vim.notify "cancelled"
            end
          end)
        end
      end

      local function help_tags(opts)
        return function()
          require "core.lazy.all"()
          builtin "help_tags"(opts)()
        end
      end

      keymap.set("n", "<Leader>f:", builtin "command_history" {}, { desc = "Telescope command_history" })
      keymap.set("n", "<Leader>fG", builtin "grep_string" {}, { desc = "Telescope grep_string" })
      keymap.set("n", "<Leader>fH", help_tags { lang = "en" }, { desc = "Telescope help_tags lang=en" })
      keymap.set("n", "<Leader>fN", extensions("node_modules", "list") {}, { desc = "Telescope node_modules" })
      keymap.set("n", "<Leader>fg", builtin "live_grep" {}, { desc = "Telescope live_grep" })
      keymap.set("n", "<Leader>fh", help_tags {}, { desc = "Telescope help_tags" })
      keymap.set(
        "n",
        "<S-Space>",
        builtin "keymaps" {
          filter = function(keymap)
            return not keymap.desc or keymap.desc ~= "Nvim builtin"
          end,
        },
        { desc = "Telescope keymaps" }
      )
      keymap.set("n", "<Leader>fm", builtin "man_pages" { sections = { "ALL" } }, { desc = "Telescope man_pages" })
      keymap.set("n", "<Leader>fn", extensions("notify", "notify") {}, { desc = "Telescope notify" })
      keymap.set("n", "<Leader>fo", frecency {}, { desc = "Telescope frecency" })
      keymap.set("n", "<Leader>fc", extensions("ctags_outline", "outline") {}, { desc = "Telescope ctags_outline" })
      keymap.set(
        "n",
        "<Leader>fq",
        extensions("ghq", "list") {
          attach_mappings = function(_)
            local actions_set = require "telescope.actions.set"
            actions_set.select:replace(function(_, _)
              local from_entry = require "telescope.from_entry"
              local actions_state = require "telescope.actions.state"
              local entry = actions_state.get_selected_entry()
              local dir = from_entry.path(entry) --[[@as string]]
              assert(uv.chdir(dir))
              frecency { workspace = "CWD" }()
            end)
            return true
          end,
        },
        { desc = "Telescope ghq" }
      )
      keymap.set("n", "<Leader>fr", builtin "resume" {}, { desc = "Telescope resume" })
      keymap.set(
        "n",
        "<Leader>ft",
        extensions("todo-comments", "todo-comments") {},
        { desc = "Telescope todo-comments" }
      )

      keymap.set("n", "<Leader>fv", frecency { workspace = "VIM" }, { desc = "Telescope file_browser $VIMRUNTIME" })
      keymap.set("n", "<Leader>fy", extensions("yank_history", "yank_history") {}, { desc = "Telescope yank_history" })

      keymap.set("n", "<Leader>fz", function()
        extensions("z", "list") {
          previewer = require("telescope.previewers.term_previewer").new_termopen_previewer {
            get_command = function(entry)
              return { "tree", "-hL", "3", require("telescope.from_entry").path(entry) }
            end,
            scroll_fn = function(self, direction)
              if not self.state then
                return
              end
              local bufnr = self.state.termopen_bufnr
              -- 0x05 -> <C-e>
              -- 0x19 -> <C-y>
              local input = direction > 0 and string.char(0x05) or string.char(0x19)
              local count = math.abs(direction)
              api.win_call(fn.bufwinid(bufnr), function()
                vim.cmd.normal { args = { count .. input }, bang = true }
              end)
            end,
          },
        }()
      end, { desc = "Telescope z" })

      -- Memo
      keymap.set("n", "<Leader>mm", extensions("memo", "list") {}, { desc = "Telescope memo" })
      keymap.set("n", "<Leader>mg", extensions("memo", "grep"), { desc = "Telescope memo grep" })

      -- LSP
      keymap.set("n", "<Leader>sr", builtin "lsp_references" {}, { desc = "Telescope lsp_references" })
      keymap.set("n", "<Leader>sd", function()
        if vim.opt.filetype:get() == "perl" then
          extensions("ctags_outline", "outline") {}()
        else
          builtin "lsp_document_symbols" {}()
        end
      end, { desc = "Telescope lsp_document_symbols or ctags_outline" })
      keymap.set("n", "<Leader>sw", builtin "lsp_workspace_symbols" {}, { desc = "Telescope lsp_workspace_symbols" })
      keymap.set("n", "<Leader>sc", builtin "lsp_code_actions" {}, { desc = "Telescope lsp_code_actions" })

      -- Git
      keymap.set("n", "<Leader>gc", builtin "git_commits" {}, { desc = "Telescope git_commits" })
      keymap.set("n", "<Leader>gb", builtin "git_bcommits" {}, { desc = "Telescope git_bcommits" })
      keymap.set("n", "<Leader>gr", builtin "git_branches" {}, { desc = "Telescope git_branches" })
      keymap.set("n", "<Leader>gs", builtin "git_status" {}, { desc = "Telescope git_status" })

      -- Copied from telescope.nvim
      keymap.set("n", "q:", builtin "command_history" {}, { desc = "Telescope command_history" })
      keymap.set(
        "c",
        "<A-r>",
        [[<C-\>e ]]
          .. [["lua require'telescope.builtin'.command_history{]]
          .. [[default_text = [=[" . escape(getcmdline(), '"') . "]=]}"<CR><CR>]],
        { silent = true, desc = "Telescope command_history" }
      )
    end,

    config = function()
      local actions = require "telescope.actions"
      local actions_state = require "telescope.actions.state"
      local telescope = require "telescope"
      local from_entry = require "telescope.from_entry"
      local Path = require "plenary.path"
      local fb_actions = require "telescope._extensions.file_browser.actions"

      local function run_builtin_in_dir(name)
        return function()
          local source = require("telescope.builtin")[name]
          local entry = actions_state.get_selected_entry()
          local dir = from_entry.path(entry)
          if Path:new(dir):is_dir() then
            source { cwd = dir }
          else
            vim.notify(("This is not a directory: %s"):format(dir), vim.log.levels.ERROR)
          end
        end
      end

      local function run_octo_in_dir(name)
        return function()
          vim.notify("opening " .. name .. " in Octo")
          local picker = require "octo.picker"
          local utils = require "octo.utils"
          local octo = require "core.utils.octo"
          local entry = actions_state.get_selected_entry()
          local dir = from_entry.path(entry)
          if not Path:new(dir):is_dir() then
            vim.notify("This is not a directory: " .. dir, vim.log.levels.ERROR)
            return
          end
          api.set_current_dir(dir)
          local repo = utils.get_remote()
          if octo.current_host ~= repo.host then
            octo.current_host = repo.host
            octo:setup()
          end
          picker[name] { repo = repo.name }
        end
      end

      local function run_frecency_in_dir()
        local source = telescope.extensions.frecency.frecency
        local entry = actions_state.get_selected_entry()
        local dir = from_entry.path(entry) --[[@as string]]
        if Path:new(dir):is_dir() then
          assert(uv.chdir(dir))
          source { workspace = "CWD" }
        else
          vim.notify(("This is not a directory: %s"):format(dir), vim.log.levels.ERROR)
        end
      end

      telescope.setup {
        defaults = {
          mappings = {
            i = {
              ["<A-i>"] = run_octo_in_dir "issues",
              ["<A-n>"] = actions.cycle_history_next,
              ["<A-o>"] = actions.send_selected_to_loclist + actions.open_loclist,
              ["<A-p>"] = actions.cycle_history_prev,
              ["<A-r>"] = run_octo_in_dir "prs",
              ["<C-a>"] = run_frecency_in_dir,
              ["<C-g>"] = run_builtin_in_dir "live_grep",
              ["<C-o>"] = actions.send_to_loclist + actions.open_loclist,

              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,

              ["<C-s>"] = actions.select_horizontal,

              ["<C-A-h>"] = actions.preview_scrolling_left,
              ["<C-A-l>"] = actions.preview_scrolling_right,

              ["<A-u>"] = actions.results_scrolling_up,
              ["<A-d>"] = actions.results_scrolling_down,
              ["<A-h>"] = actions.results_scrolling_left,
              ["<A-l>"] = actions.results_scrolling_right,
            },
          },
          layout_config = {
            scroll_speed = 3,
          },
          vimgrep_arguments = {
            "pt",
            "--nocolor",
            "--nogroup",
            "--column",
            "--smart-case",
            "--hidden",
          },
          history = {
            path = Path:new(fn.stdpath "data", "telescope_history.sqlite3").filename,
            limit = 100,
          },
          winblend = 10,
          prompt_prefix = "❯❯❯ ",
          selection_caret = "❯ ",
          dynamic_preview_title = true,
        },
        extensions = {
          file_browser = {
            mappings = {
              i = {
                ["<C-a>"] = run_frecency_in_dir,
                ["<C-g>"] = run_builtin_in_dir "live_grep",
                ["<C-x>"] = fb_actions.toggle_all,
                ["<C-s>"] = actions.select_horizontal,
              },
            },
            theme = "ivy",
            hijack_netrw = true,
            dir_icon_hl = "Directory",
            icon_width = 2,
            path_display = { "shorten", "smart" },
            respect_gitignore = false,
            layout_config = {
              height = function(_, _, max_lines)
                return math.max(math.floor(max_lines / 2), 5)
              end,
            },
          },
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          ---@type FrecencyConfig
          frecency = {
            show_scores = true,
            show_filter_column = { "LSP", "CWD", "VIM" },
            workspaces = {
              VIM = vim.env.VIMRUNTIME,
            },
          },
        },
      }

      telescope.load_extension "file_browser"
      telescope.load_extension "frecency"
      -- NOTE: This is needed to setup telescope-fzf-native. It overrides the
      -- sorters in this.
      telescope.load_extension "fzf"
      telescope.load_extension "smart_history"
      telescope.load_extension "noice"
      telescope.load_extension "notify"
      telescope.load_extension "yank_history"
      telescope.load_extension "ctags_outline"
      telescope.load_extension "todo-comments"

      require("dressing").setup {}

      -- Set mappings for yanky here to avoid cycle referencing
      local utils = require "yanky.utils"
      local mapping = require "yanky.telescope.mapping"
      local options = require("yanky.config").options
      options.picker.telescope.mappings = {
        default = mapping.put "p",
        i = {
          ["<A-p>"] = mapping.put "p",
          ["<A-P>"] = mapping.put "P",
          ["<A-d>"] = mapping.delete(),
          ["<A-r>"] = mapping.set_register(utils.get_default_register()),
        },
        n = {
          p = mapping.put "p",
          P = mapping.put "P",
          d = mapping.delete(),
          r = mapping.set_register(utils.get_default_register()),
        },
      }
      require("yanky.config").setup(options)

      -- Command palette
      -- https://blog.atusy.net/2022/11/03/telescope-as-command-pallete/
      for k, v in pairs(require "telescope.builtin") do
        vim.keymap.set("n", "<Plug>(telescope-" .. k .. ")", v, { desc = "Telescope " .. k })
      end
      for k, v in pairs(require "octo.mappings") do
        vim.keymap.set("n", "<Plug>(Octo-" .. k .. ")", v, { desc = "Octo " .. k })
      end
      vim.keymap.set(
        "n",
        "<Plug>(Octo-review-list)",
        "<Cmd>Octo search review-requested:@me is:open is:pr archived:false<CR>"
      )
      vim.keymap.set(
        "n",
        "<Plug>(Octo-review-again-list)",
        "<Cmd>Octo search reviewed-by:@me -review:approved is:open is:pr archived:false<CR>"
      )
      vim.keymap.set(
        "n",
        "<Plug>(Octo-review-done-list)",
        "<Cmd>Octo search reviewed-by:@me review:approved is:open is:pr archived:false<CR>"
      )
    end,
  },
}
