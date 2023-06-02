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
      { "nvim-lua/popup.nvim" },
      { "nvim-telescope/telescope-file-browser.nvim" },
      {
        "nvim-telescope/telescope-frecency.nvim",
        --"delphinus/telescope-frecency.nvim",
        branch = "refactor-again",
        dependencies = { "kkharji/sqlite.lua" },
      },
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
      local frecency = require "core.telescope.frecency"

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

      -- Lines
      keymap.set("n", "#", builtin "current_buffer_fuzzy_find" {}, { desc = "Telescope current_buffer_fuzzy_find" })

      -- Files
      keymap.set("n", "<Leader>fB", builtin "buffers" {}, { desc = "Telescope buffers" })
      keymap.set("n", "<Leader>fb", function()
        local cwd = fn.expand "%:h"
        extensions("file_browser", "file_browser") { cwd = cwd ~= "" and cwd or nil }()
      end, { desc = "Telescope file_browser" })
      keymap.set("n", "<Leader>ff", function()
        local Path = require "plenary.path"
        -- TODO: stopgap measure
        if uv.cwd() == uv.os_homedir() then
          vim.notify("find_files on $HOME is danger. Launch file_browser instead.", vim.log.levels.WARN)
          extensions("file_browser", "file_browser") {}()
        elseif Path:new(uv.cwd() .. "/.git"):is_dir() then
          builtin "git_files" { show_untracked = true }()
        else
          builtin "find_files" { hidden = true }()
        end
      end, { desc = "Telescope git_files or find_files" })

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
      keymap.set(
        "n",
        "<Leader>fg",
        input_grep_string("Grep For ❯ ", builtin "grep_string"),
        { desc = "Telescope grep_string" }
      )
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
      keymap.set(
        "n",
        "<Leader>fo",
        extensions("frecency", "frecency") { path_display = frecency.path_display },
        { desc = "Telescope frecency" }
      )
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
              local dir = from_entry.path(entry)
              builtin "git_files" { cwd = dir, show_untracked = true }()
            end)
            return true
          end,
        },
        { desc = "Telescope ghq" }
      )
      keymap.set("n", "<Leader>fr", builtin "resume" {}, { desc = "Telescope resume" })

      keymap.set(
        "n",
        "<Leader>fv",
        extensions("file_browser", "file_browser") {
          add_dirs = false,
          depth = false,
          hide_parent_dir = true,
          path = "$VIMRUNTIME",
        },
        { desc = "Telescope file_browser $VIMRUNTIME" }
      )
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
      keymap.set(
        "n",
        "<Leader>mg",
        input_grep_string("Memo Grep For ❯ ", extensions("memo", "grep_string")),
        { desc = "Telescope memo grep_string" }
      )

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

      -- for telescope-frecency
      api.create_autocmd({ "BufWinEnter", "BufWritePost" }, {
        desc = "Set up telescope-frecency",
        group = api.create_augroup("TelescopeFrecency", {}),
        callback = function(args)
          local path = vim.api.nvim_buf_get_name(args.buf)
          if path and path ~= "" then
            local st = uv.fs_stat(path)
            if st then
              local ok, db_client = pcall(require, "telescope._extensions.frecency.db_client")
              if ok then
                db_client.init(nil, nil, true, true)
                db_client.autocmd_handler(path)
              else
                local ok, db = pcall(require, "frecency.db")
                if ok then
                  db.update(path)
                end
              end
            end
          end
        end,
      })
    end,

    config = function()
      local actions = require "telescope.actions"
      local actions_state = require "telescope.actions.state"
      local telescope = require "telescope"
      local from_entry = require "telescope.from_entry"
      local Path = require "plenary.path"
      local fb_actions = require "telescope._extensions.file_browser.actions"

      local run_builtin_in_dir = function(name)
        return function()
          local source = require("telescope.builtin")[name]
          local entry = actions_state.get_selected_entry()
          local dir = from_entry.path(entry)
          if fn.isdirectory(dir) then
            source { cwd = dir }
          else
            vim.notify(("This is not a directory: %s"):format(dir), vim.log.levels.ERROR)
          end
        end
      end

      local run_octo_in_dir = function(name)
        return function()
          vim.notify("opening " .. name .. " in Octo")
          local picker = require "octo.picker"
          local utils = require "octo.utils"
          local octo = require "core.utils.octo"
          local entry = actions_state.get_selected_entry()
          local dir = from_entry.path(entry)
          if not fn.isdirectory(dir) then
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

      local preview_scroll = function(direction)
        return function(prompt_bufnr)
          actions.get_current_picker(prompt_bufnr).previewer:scroll_fn(direction)
        end
      end

      telescope.setup {
        defaults = {
          mappings = {
            i = {
              ["<A-i>"] = run_octo_in_dir "issues",
              ["<A-p>"] = run_octo_in_dir "prs",
              ["<C-a>"] = run_builtin_in_dir "find_files",
              ["<C-c>"] = actions.close,
              ["<C-g>"] = run_builtin_in_dir "live_grep",
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-l>"] = actions.send_to_loclist + actions.open_loclist,
              ["<M-l>"] = actions.send_selected_to_loclist + actions.open_loclist,
            },
            n = {
              ["<Space>"] = actions.toggle_selection,
              ["<C-a>"] = run_builtin_in_dir "find_files",
              ["<C-b>"] = actions.results_scrolling_up,
              ["<C-c>"] = actions.close,
              ["<C-f>"] = actions.results_scrolling_down,
              ["<C-g>"] = run_builtin_in_dir "live_grep",
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-n>"] = actions.select_horizontal,
              ["<C-d>"] = preview_scroll(3),
              ["<C-u>"] = preview_scroll(-3),
              ["<C-l>"] = actions.send_to_loclist + actions.open_loclist,
              ["<M-l>"] = actions.send_selected_to_loclist + actions.open_loclist,
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
                ["<A-d>"] = fb_actions.remove,
                ["<A-e>"] = fb_actions.create, -- Original: <A-c>
                ["<A-g>"] = fb_actions.goto_parent_dir, -- Original: <C-g>
                ["<A-h>"] = fb_actions.toggle_hidden, -- Original: <C-h>
                ["<A-m>"] = fb_actions.move,
                ["<A-r>"] = fb_actions.rename,
                ["<A-s>"] = fb_actions.toggle_all, -- Original: <C-s>
                ["<A-y>"] = fb_actions.copy,
                ["<C-a>"] = run_builtin_in_dir "find_files",
                ["<C-d>"] = preview_scroll(3),
                ["<C-e>"] = fb_actions.goto_home_dir,
                ["<C-f>"] = fb_actions.toggle_browser,
                ["<C-g>"] = run_builtin_in_dir "live_grep",
                ["<C-n>"] = actions.select_horizontal,
                ["<C-o>"] = fb_actions.open,
                ["<C-s>"] = actions.select_horizontal,
                ["<C-t>"] = fb_actions.change_cwd,
                ["<C-u>"] = preview_scroll(-3),
                ["<C-w>"] = fb_actions.goto_cwd,
              },
              n = {
                ["<C-a>"] = run_builtin_in_dir "find_files",
                ["<C-d>"] = preview_scroll(3),
                ["<C-g>"] = run_builtin_in_dir "live_grep",
                ["<C-u>"] = preview_scroll(-3),
                ["c"] = fb_actions.create,
                ["d"] = fb_actions.remove,
                ["e"] = fb_actions.goto_home_dir,
                ["f"] = fb_actions.toggle_browser,
                ["g"] = fb_actions.goto_parent_dir,
                ["h"] = fb_actions.toggle_hidden,
                ["m"] = fb_actions.move,
                ["o"] = fb_actions.open,
                ["r"] = fb_actions.rename,
                ["s"] = fb_actions.toggle_all,
                ["t"] = fb_actions.change_cwd,
                ["w"] = fb_actions.goto_cwd,
                ["y"] = fb_actions.copy,
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
      -- This is needed to setup telescope-frecency.
      telescope.load_extension "frecency"
      -- This is needed to setup telescope-fzf-native. It overrides the sorters
      -- in this.
      telescope.load_extension "fzf"
      -- This is needed to setup telescope-smart-history.
      telescope.load_extension "smart_history"
      -- This is needed to setup noice.nvim
      telescope.load_extension "noice"
      -- This is needed to setup nvim-notify
      telescope.load_extension "notify"
      -- This is needed to setup yanky
      telescope.load_extension "yank_history"
      -- This is needed to setup ctags-outline
      telescope.load_extension "ctags_outline"

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
