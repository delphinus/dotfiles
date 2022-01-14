local function o(plugin)
  plugin.opt = true
  return plugin
end

return {
  o { "delphinus/telescope-memo.nvim" },
  o { "kyazdani42/nvim-web-devicons" },
  o { "nvim-lua/popup.nvim" },
  o { "nvim-telescope/telescope-file-browser.nvim" },
  o { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
  o { "nvim-telescope/telescope-ghq.nvim" },
  o { "nvim-telescope/telescope-github.nvim" },
  o { "nvim-telescope/telescope-node-modules.nvim" },
  o { "nvim-telescope/telescope-symbols.nvim" },
  o { "nvim-telescope/telescope-z.nvim" },

  o {
    "nvim-telescope/telescope-smart-history.nvim",
    requires = o { "tami5/sql.nvim" },
    wants = { "sql.nvim" },
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    module_pattern = { "telescope.*" },
    requires = {
      { "plenary.nvim" },
    },
    wants = {
      "nvim-web-devicons",
      "popup.nvim",
      "telescope-file-browser.nvim",
      "telescope-fzf-native.nvim",
      "telescope-ghq.nvim",
      "telescope-github.nvim",
      "telescope-memo.nvim",
      "telescope-node-modules.nvim",
      "telescope-smart-history.nvim",
      "telescope-symbols.nvim",
      "telescope-z.nvim",
    },

    setup = function()
      local builtin = function(name)
        return function(opt)
          return function()
            return require("telescope.builtin")[name](opt or {})
          end
        end
      end
      local extensions = function(name, prop)
        return function(opt)
          return function()
            local telescope = require "telescope"
            telescope.load_extension(name)
            return telescope.extensions[name][prop](opt or {})
          end
        end
      end
      local path_display = function(_, path)
        local home = "^" .. loop.os_homedir()
        local gh_dir = home .. "/git/github.com"
        local gh_e_dir = home .. "/git/" .. vim.g.gh_e_host
        local ghq_dir = home .. "/git"
        local packer_dir = home .. "/.local/share/nvim/site/pack/packer"
        return path
          :gsub(gh_dir, "$GH")
          :gsub(gh_e_dir, "$GH_E")
          :gsub(ghq_dir, "$GIT")
          :gsub(packer_dir, "$PACKER")
          :gsub(home, "~")
      end

      -- Lines
      vim.keymap.set("n", "#", builtin "current_buffer_fuzzy_find" {})

      -- Files
      vim.keymap.set("n", "<Leader>fB", builtin "buffers" {})
      vim.keymap.set("n", "<Leader>fb", function()
        local cwd = fn.expand "%:h"
        extensions("file_browser", "file_browser") { cwd = cwd == "" and nil or cwd }()
      end)
      vim.keymap.set("n", "<Leader>ff", function()
        -- TODO: stopgap measure
        if loop.cwd() == loop.os_homedir() then
          api.echo({
            {
              "find_files on $HOME is danger. Launch file_browser instead.",
              "WarningMsg",
            },
          }, true, {})
          extensions("file_browser", "file_browser") {}()
          -- TODO: use loop.fs_stat ?
        elseif fn.isdirectory(loop.cwd() .. "/.git") == 1 then
          builtin "git_files" {}()
        else
          builtin "find_files" { hidden = true }()
        end
      end)
      vim.keymap.set("n", "<Leader>fg", function()
        builtin "grep_string" {
          only_sort_text = true,
          search = fn.input "Grep For ❯ ",
        }()
      end)
      vim.keymap.set("n", "<Leader>f:", builtin "command_history" {})
      vim.keymap.set("n", "<Leader>fG", builtin "grep_string" {})
      vim.keymap.set("n", "<Leader>fH", builtin "help_tags" { lang = "en" })
      vim.keymap.set("n", "<Leader>fh", builtin "help_tags" {})
      vim.keymap.set("n", "<Leader>fm", builtin "man_pages" { sections = { "ALL" } })
      vim.keymap.set("n", "<Leader>fn", extensions("node_modules", "list") {})
      vim.keymap.set("n", "<Leader>fo", builtin "oldfiles" { path_display = path_display })
      vim.keymap.set("n", "<Leader>fp", extensions("projects", "projects") {})
      vim.keymap.set("n", "<Leader>fq", extensions("ghq", "list") {})
      vim.keymap.set("n", "<Leader>fr", builtin "resume" {})
      vim.keymap.set("n", "<Leader>fz", extensions("z", "list") {})

      -- Memo
      vim.keymap.set("n", "<Leader>mm", extensions("memo", "list") {})
      vim.keymap.set("n", "<Leader>mg", function()
        extensions("memo", "grep_string") {
          only_sort_text = true,
          search = fn.input "Memo Grep For ❯ ",
        }()
      end)

      -- LSP
      vim.keymap.set("n", "<Leader>sr", builtin "lsp_references" {})
      vim.keymap.set("n", "<Leader>sd", builtin "lsp_document_symbols" {})
      vim.keymap.set("n", "<Leader>sw", builtin "lsp_workspace_symbols" {})
      vim.keymap.set("n", "<Leader>sc", builtin "lsp_code_actions" {})

      -- Git
      vim.keymap.set("n", "<Leader>gc", builtin "git_commits" {})
      vim.keymap.set("n", "<Leader>gb", builtin "git_bcommits" {})
      vim.keymap.set("n", "<Leader>gr", builtin "git_branches" {})
      vim.keymap.set("n", "<Leader>gs", builtin "git_status" {})

      -- Copied from telescope.nvim
      vim.keymap.set(
        "c",
        "<A-r>",
        [[<C-\>e ]]
          .. [["lua require'telescope.builtin'.command_history{]]
          .. [[default_text = [=[" . escape(getcmdline(), '"') . "]=]}"<CR><CR>]],
        { silent = true }
      )
    end,

    config = function()
      local actions = require "telescope.actions"
      local actions_state = require "telescope.actions.state"
      local telescope = require "telescope"
      local from_entry = require "telescope.from_entry"
      local Path = require "plenary.path"
      local fb_actions = require "telescope._extensions.file_browser.actions"

      local run_in_dir = function(name)
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

      local preview_scroll = function(direction)
        return function(prompt_bufnr)
          actions.get_current_picker(prompt_bufnr).previewer:scroll_fn(direction)
        end
      end

      telescope.setup {
        defaults = {
          mappings = {
            i = {
              ["<C-a>"] = run_in_dir "find_files",
              ["<C-c>"] = actions.close,
              ["<C-g>"] = run_in_dir "live_grep",
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<C-u>"] = actions.preview_scrolling_up,
              -- https://github.com/nvim-telescope/telescope.nvim/issues/1579
              ["<C-w>"] = function()
                vim.cmd [[normal! bcw]]
              end,
            },
            n = {
              ["<C-a>"] = run_in_dir "find_files",
              ["<C-c>"] = actions.close,
              ["<C-g>"] = run_in_dir "live_grep",
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-n>"] = actions.select_horizontal,
              ["<C-d>"] = preview_scroll(3),
              ["<C-u>"] = preview_scroll(-3),
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
                ["<C-a>"] = run_in_dir "find_files",
                ["<C-d>"] = preview_scroll(3),
                ["<C-e>"] = fb_actions.goto_home_dir,
                ["<C-f>"] = fb_actions.toggle_browser,
                ["<C-g>"] = run_in_dir "live_grep",
                ["<C-n>"] = actions.select_horizontal,
                ["<C-o>"] = fb_actions.open,
                ["<C-s>"] = actions.select_horizontal,
                ["<C-t>"] = fb_actions.change_cwd,
                ["<C-u>"] = preview_scroll(-3),
                ["<C-w>"] = fb_actions.goto_cwd,
              },
              n = {
                ["<C-a>"] = run_in_dir "find_files",
                ["<C-d>"] = preview_scroll(3),
                ["<C-g>"] = run_in_dir "live_grep",
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
          },
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      }
      telescope.load_extension "file_browser"
      -- This is needed to setup telescope-fzf-native. It overrides the sorters
      -- in this.
      telescope.load_extension "fzf"
      -- This is needed to setup telescope-smart-history.
      telescope.load_extension "smart_history"
      -- This is needed to setup projects.nvim
      telescope.load_extension "projects"
    end,
  },
}
