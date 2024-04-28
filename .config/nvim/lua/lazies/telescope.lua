local fn, uv, api = require("core.utils").globals()
local utils = require "core.utils"
local palette = require "core.utils.palette"

return {
  {
    "d00h/telescope-any",
    dependencies = { { "telescope.nvim" } },
    init = function()
      local core = require "core.telescope"
      local instance
      vim.keymap.set("n", "<Leader><Leader>", function()
        if not instance then
          instance = require("telescope-any").create_telescope_any {
            pickers = {
              [":"] = core.builtin "command_history" {},
              ["/"] = core.extensions "egrepify" {},
              ["?"] = core.builtin "grep_string" {},

              ["m "] = core.builtin "marks" {},
              ["q "] = core.builtin "quickfix" {},
              ["l "] = core.builtin "loclist" {},
              ["j "] = core.builtin "jumplist" {},

              ["man "] = core.builtin "man_pages" {},
              ["options "] = core.builtin "vim_options" {},
              ["keymaps "] = core.builtin "keymaps" {},

              ["colorscheme "] = core.builtin "colorscheme" {},
              ["colo "] = core.builtin "colorscheme" {},

              ["com "] = core.builtin "commands" {},
              ["command "] = core.builtin "commands" {},

              ["au "] = core.builtin "autocommands" {},
              ["autocommand "] = core.builtin "autocommands" {},

              ["highlight "] = core.builtin "highlights" {},
              ["hi "] = core.builtin "highlights" {},

              ["ctags "] = core.extensions "ctags_outline" {},

              ["o "] = core.frecency {},
              ["b "] = core.builtin "buffers" {},

              ["gs "] = core.builtin "git_status" {},
              ["gb "] = core.builtin "git_branches" {},
              ["gc "] = core.builtin "git_commits" {},

              ["d "] = core.builtin "diagnostics" {},
              ["@"] = core.builtin "lsp_document_symbols" {},

              ["B "] = function(opts)
                local parent = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
                core.extensions "file_browser" { cwd = parent ~= "" and parent or nil }(opts)
              end,

              ["# "] = core.builtin "current_buffer_fuzzy_find" {},
              ["h "] = core.help_tags {},
              ["H "] = core.help_tags { lang = "en" },
              ["node "] = core.extensions("node_modules", "list") {},
              ["N "] = core.extensions("node_modules", "list") {},
              ["todo "] = core.extensions "todo-comments" {},
              ["t "] = core.extensions "todo-comments" {},
              ["yank"] = core.extensions "yank_history" {},
              ["y "] = core.extensions "yank_history" {},

              ["f "] = core.frecency { workspace = "CWD" },
              ["v "] = core.frecency { workspace = "VIM" },

              [""] = core.frecency {},
            },
          }
        end
        instance()
      end, { desc = "Open telescope-any" })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    -- set modules in detail because telescope-frecency is needed before
    -- telescope itself to save its history in opening buffers.
    dependencies = {
      { "lambdalisue/kensaku.vim" },
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

      { "nvim-telescope/telescope-file-browser.nvim" },
      { "nvim-telescope/telescope-frecency.nvim", branch = "feat/fuzzy-match" },
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "nvim-telescope/telescope-ghq.nvim" },
      { "nvim-telescope/telescope-github.nvim" },
      { "nvim-telescope/telescope-media-files.nvim" },
      { "nvim-telescope/telescope-node-modules.nvim" },
      { "nvim-telescope/telescope-smart-history.nvim", dependencies = { "kkharji/sqlite.lua" } },
      { "nvim-telescope/telescope-symbols.nvim" },
      { "nvim-telescope/telescope-z.nvim" },

      { "jonarrien/telescope-cmdline.nvim" },
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
      {
        "fdschmidt93/telescope-egrepify.nvim",
        branch = "feat/ts-highlight",
        init = function()
          palette "egrepify" {
            nord = function(colors)
              api.set_hl(0, "EgrepifyFile", { fg = colors.orange })
              api.set_hl(0, "EgrepifyLnum", { fg = colors.green })
            end,
          }
        end,
      },
    },

    init = function()
      palette "telescope" {
        nord = function(colors)
          api.set_hl(0, "TelescopeMatching", { fg = colors.magenta })
          api.set_hl(0, "TelescopePreviewBorder", { fg = colors.green })
          api.set_hl(0, "TelescopePromptBorder", { fg = colors.cyan })
          api.set_hl(0, "TelescopeResultsBorder", { fg = colors.blue })
          api.set_hl(0, "TelescopeSelection", { fg = colors.blue })
          api.set_hl(0, "TelescopeSelectionCaret", { fg = colors.blue })
        end,
      }

      local core = require "core.telescope"

      -- Lines
      vim.keymap.set(
        "n",
        "#",
        core.builtin "current_buffer_fuzzy_find" {},
        { desc = "Telescope current_buffer_fuzzy_find" }
      )

      -- Files
      vim.keymap.set("n", "<Leader>fB", core.builtin "buffers" {}, { desc = "Telescope buffers" })
      vim.keymap.set("n", "<Leader>fb", function()
        local cwd = fn.expand "%:h"
        core.extensions "file_browser" { cwd = cwd ~= "" and cwd or nil }()
      end, { desc = "Telescope file_browser" })
      vim.keymap.set("n", "<Leader>ff", core.frecency { workspace = "CWD" }, { desc = "Telescope frecency on CWD" })

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
          core.builtin "help_tags"(opts)()
        end
      end

      vim.keymap.set("n", "<Leader>f:", core.builtin "command_history" {}, { desc = "Telescope command_history" })
      vim.keymap.set("n", "<Leader>fG", core.builtin "grep_string" {}, { desc = "Telescope grep_string" })
      vim.keymap.set("n", "<Leader>fH", help_tags { lang = "en" }, { desc = "Telescope help_tags lang=en" })
      vim.keymap.set("n", "<Leader>fN", core.extensions("node_modules", "list") {}, { desc = "Telescope node_modules" })
      vim.keymap.set("n", "<Leader>fg", core.extensions "egrepify" {}, { desc = "Telescope egrepify" })
      vim.keymap.set("n", "<Leader>fM", function()
        utils.load_denops_plugin "kensaku.vim"
        core.extensions "egrepify" {
          on_input_filter_cb = function(prompt)
            return { prompt = vim.fn["kensaku#query"](prompt, { rxop = vim.g["kensaku#rxop#javascript"] }) }
          end,
        } {}
      end)
      vim.keymap.set("n", "<Leader>fh", help_tags {}, { desc = "Telescope help_tags" })
      vim.keymap.set(
        "n",
        "<A-Space>",
        core.builtin "keymaps" {
          filter = function(keymap)
            return not keymap.desc or keymap.desc ~= "Nvim builtin"
          end,
        },
        { desc = "Telescope keymaps" }
      )
      vim.keymap.set(
        "n",
        "<Leader>fm",
        core.builtin "man_pages" { sections = { "ALL" } },
        { desc = "Telescope man_pages" }
      )
      vim.keymap.set("n", "<Leader>fn", core.extensions "noice" {}, { desc = "Telescope noice" })
      vim.keymap.set("n", "<Leader>fo", core.frecency {}, { desc = "Telescope frecency" })
      vim.keymap.set("n", "<Leader>fc", core.extensions "ctags_outline" {}, { desc = "Telescope ctags_outline" })
      vim.keymap.set(
        "n",
        "<Leader>fq",
        core.extensions "ghq" {
          attach_mappings = function(_)
            local actions_set = require "telescope.actions.set"
            actions_set.select:replace(function(_, _)
              local from_entry = require "telescope.from_entry"
              local actions_state = require "telescope.actions.state"
              local entry = actions_state.get_selected_entry()
              local dir = from_entry.path(entry) --[[@as string]]
              assert(uv.chdir(dir))
              core.frecency { workspace = "CWD" }()
            end)
            return true
          end,
        },
        { desc = "Telescope ghq" }
      )
      vim.keymap.set("n", "<Leader>fr", core.builtin "resume" {}, { desc = "Telescope resume" })
      vim.keymap.set("n", "<Leader>ft", core.extensions "todo-comments" {}, { desc = "Telescope todo-comments" })

      vim.keymap.set(
        "n",
        "<Leader>fv",
        core.frecency { workspace = "VIM" },
        { desc = "Telescope file_browser $VIMRUNTIME" }
      )
      vim.keymap.set("n", "<Leader>fy", core.extensions "yank_history" {}, { desc = "Telescope yank_history" })

      vim.keymap.set("n", "<Leader>fz", function()
        core.extensions "z" {
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
      vim.keymap.set("n", "<Leader>mm", core.extensions("memo", "list") {}, { desc = "Telescope memo" })
      vim.keymap.set("n", "<Leader>mg", core.extensions("memo", "grep") {}, { desc = "Telescope memo grep" })

      -- LSP
      vim.keymap.set("n", "<Leader>sr", core.builtin "lsp_references" {}, { desc = "Telescope lsp_references" })
      vim.keymap.set("n", "<Leader>sd", function()
        if
          vim.iter(vim.lsp.get_clients()):any(function(client)
            client.supports_method "textDocument/documentSymbol"
          end)
        then
          core.builtin "lsp_document_symbols" {}()
        else
          core.extensions "ctags_outline" {}()
        end
      end, { desc = "Telescope lsp_document_symbols or ctags_outline" })
      vim.keymap.set(
        "n",
        "<Leader>sw",
        core.builtin "lsp_workspace_symbols" {},
        { desc = "Telescope lsp_workspace_symbols" }
      )
      vim.keymap.set("n", "<Leader>sc", core.builtin "lsp_code_actions" {}, { desc = "Telescope lsp_code_actions" })

      -- Git
      vim.keymap.set("n", "<Leader>gc", core.builtin "git_commits" {}, { desc = "Telescope git_commits" })
      vim.keymap.set("n", "<Leader>gb", core.builtin "git_bcommits" {}, { desc = "Telescope git_bcommits" })
      vim.keymap.set("n", "<Leader>gr", core.builtin "git_branches" {}, { desc = "Telescope git_branches" })
      vim.keymap.set("n", "<Leader>gs", core.builtin "git_status" {}, { desc = "Telescope git_status" })
      vim.keymap.set("v", "<Leader>gl", function()
        local from = fn.line "v"
        local to = vim.api.nvim_win_get_cursor(0)[1]
        core.builtin "git_bcommits_range" { from = from, to = to }()
      end, { desc = "Telescope git_branches" })

      -- Copied from telescope.nvim
      vim.keymap.set("n", "q:", core.builtin "command_history" {}, { desc = "Telescope command_history" })
      vim.keymap.set(
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
      local actions_layout = require "telescope.actions.layout"
      local telescope = require "telescope"
      local from_entry = require "telescope.from_entry"
      local Path = require "plenary.path"
      local fb_actions = require "telescope._extensions.file_browser.actions"

      local function run_extension_in_dir(name)
        return function()
          telescope.load_extension(name)
          local entry = actions_state.get_selected_entry()
          local dir = from_entry.path(entry)
          if Path:new(dir):is_dir() then
            telescope.extensions[name][name] { cwd = dir }
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
              ["<C-g>"] = run_extension_in_dir "egrepify",
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

              ["<A-[>"] = actions_layout.cycle_layout_prev,
              ["<A-]>"] = actions_layout.cycle_layout_next,
            },
          },
          cycle_layout_list = { "center", "horizontal", "vertical" },
          history = {
            path = Path:new(fn.stdpath "data", "telescope_history.sqlite3").filename,
            limit = 100,
          },
          winblend = 10,
          prompt_prefix = "❯❯❯ ",
          selection_caret = "❯ ",
          dynamic_preview_title = true,

          -- NOTE: copy from drodown theme
          results_title = false,

          sorting_strategy = "ascending",
          layout_strategy = "center",
          layout_config = {
            scroll_speed = 3, -- NOTE: This is changed from dropdown

            preview_cutoff = 1, -- Preview should always show (unless previewer = false)

            width = function(_, max_columns, _)
              return math.min(max_columns, 80)
            end,

            height = function(_, _, max_lines)
              return math.min(max_lines, 15)
            end,
          },

          border = true,
          borderchars = {
            prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
            results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
            preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
        },
        extensions = {
          file_browser = {
            mappings = {
              i = {
                ["<A-CR>"] = fb_actions.create_from_prompt,
                ["<C-a>"] = run_frecency_in_dir,
                ["<C-g>"] = run_extension_in_dir "egrepify",
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
            matcher = "fuzzy",
            db_safe_mode = false,
            hide_current_buffer = true,
            show_scores = true,
            show_filter_column = { "LSP", "CWD", "VIM" },
            workspaces = {
              VIM = vim.env.VIMRUNTIME,
            },
            ignore_patterns = { "*.git/*", "*/tmp/*", "term://*", "*/tmux-fingers/alphabets*" },
          },
          media_files = { filetypes = { "png", "jpg", "jpeg", "gif", "mp4", "webm", "pdf" } },
          egrepify = {
            vimgrep_arguments = {
              "rg",
              "--color=never",
              "--no-heading",
              "--with-filename",
              "--line-number",
              "--column",
              "--smart-case",
              "--hidden",
            },
            results_ts_hl = true,
          },
        },
      }

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

  {
    "folke/trouble.nvim",
    branch = "dev",
    cmd = { "Trouble" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
    opts = {},
  },

  {
    "epwalsh/obsidian.nvim",
    dependencies = { "plenary.nvim", "telescope.nvim" },
    cmd = {
      "ObsidianBacklinks",
      "ObsidianDailies",
      "ObsidianExtractNote",
      "ObsidianFollowLink",
      "ObsidianLink",
      "ObsidianLinkNew",
      "ObsidianNew",
      "ObsidianOpen",
      "ObsidianPasteImg",
      "ObsidianQuickSwitch",
      "ObsidianRename",
      "ObsidianSearch",
      "ObsidianTags",
      "ObsidianTemplate",
      "ObsidianToday",
      "ObsidianToggleCheckbox",
      "ObsidianTomorrow",
      "ObsidianWorkspace",
      "ObsidianYesterday",
    },
    ft = "markdown",
    init = function()
      vim.keymap.set("n", "<Leader>os", "<Cmd>ObsidianSearch<CR>", { desc = "Search Obsidian notes" })
      vim.keymap.set("n", "<Leader>ot", "<Cmd>ObsidianToday<CR>", { desc = "Open today's note" })
      vim.keymap.set("n", "<Leader>om", "<Cmd>ObsidianTomorrow<CR>", { desc = "Open tomorrow's note" })
      vim.keymap.set("n", "<Leader>oy", "<Cmd>ObsidianYesterday<CR>", { desc = "Open yesterday's note" })
      vim.keymap.set("n", "<Leader>on", "<Cmd>ObsidianNew<CR>", { desc = "Create a new note" })
      vim.keymap.set("n", "<Leader>od", "<Cmd>ObsidianDailies<CR>", { desc = "Open daily notes" })
    end,
    opts = {
      workspaces = { { name = "default", path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes" } },
      daily_notes = { folder = "日記" },
      ---@param title string|?
      ---@return string
      note_id_func = function(title)
        local purified
        if title then
          purified = title:lower():gsub("[^-a-z0-9]+", "-"):gsub("^-+", ""):gsub("-+$", ""):gsub("-+", "-")
          if purified:match "^-*$" then
            purified = nil
          end
        end
        if not purified then
          purified = ""
          for _ = 1, 4 do
            purified = purified .. string.char(math.random(65, 90))
          end
        end
        return os.date "%Y%m%d-%H%M%S-" .. purified
      end,
      ---@param spec { id: string, dir: obsidian.Path, title: string|? }
      ---@return string|obsidian.Path The full path to the new note.
      note_path_func = function(spec)
        local path
        local filename = spec.title
        if filename then
          filename = vim.fn.substitute(filename, [=[[ \%u3000]]=], "-", "g")
          filename = vim.fn.substitute(filename, [=[['"\\/:]]=], "", "g")
          filename = filename:lower()
          path = spec.dir / (os.date "%Y%m%d-%H%M%S-" .. filename)
        else
          path = spec.dir / spec.id
        end
        return path:with_suffix ".md"
      end,
      ---@return string
      image_name_func = function()
        return tostring(os.date "%Y%m%d-%H%M%S-")
      end,
    },
  },
}
