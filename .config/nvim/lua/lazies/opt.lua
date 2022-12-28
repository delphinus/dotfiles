local fn, uv, api = require("core.utils").globals()
local lazy_require = require "lazy_require"

local function dwm(method)
  return function()
    require("dwm")[method]()
  end
end

return {
  { "vim-denops/denops.vim", event = { "CursorHold", "FocusLost" } },

  {
    --"arcticicestudio/nord-vim",
    "delphinus/nord-nvim",
    build = lazy_require("nord").update {
      italic = true,
      uniform_status_lines = true,
      uniform_diff_background = true,
      cursor_line_number_background = true,
      language_specific_highlights = false,
    },
    config = function()
      local palette = require "core.utils.palette" "nord"
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("nord_overrides", {}),
        pattern = "nord",
        callback = function()
          api.set_hl(0, "Comment", { fg = palette.comment, italic = true })
          api.set_hl(0, "Delimiter", { fg = palette.blue })
          api.set_hl(0, "Constant", { fg = palette.dark_white, italic = true })
          api.set_hl(0, "Folded", { fg = palette.comment })
          api.set_hl(0, "Identifier", { fg = palette.bright_cyan })
          api.set_hl(0, "Special", { fg = palette.orange })
          api.set_hl(0, "Title", { fg = palette.cyan, bold = true })
          api.set_hl(0, "PmenuSel", { blend = 0 })
          api.set_hl(0, "NormalFloat", { fg = palette.dark_white, bg = palette.dark_black, blend = 10 })
          api.set_hl(0, "FloatBorder", { fg = palette.bright_cyan, bg = palette.dark_black, blend = 10 })
        end,
      })
    end,
  },

  { "lifepillar/vim-solarized8" },

  {
    "akinsho/toggleterm.nvim",
    keys = {
      { "<A-c>", "<Cmd>ToggleTerm<CR>", mode = { "n", "t" }, desc = "Open ToggleTerm" },
    },
    cmd = { "ToggleTerm", "ToggleTermAll", "TermExec" },
    init = function()
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("toggleterm-colors", {}),
        pattern = "nord",
        callback = function()
          local palette = require "core.utils.palette" "nord"
          --[[
          api.set_hl(0, "WinBorderTop", { fg = "#ebf5f5", blend = 30 })
          api.set_hl(0, "WinBorderLeft", { fg = "#c2dddc", blend = 30 })
          api.set_hl(0, "WinBorderRight", { fg = "#8fbcbb", blend = 30 })
          api.set_hl(0, "WinBorderBottom", { fg = "#5d9794", blend = 30 })
          api.set_hl(0, "WinBorderLight", { fg = "#c2dddc", bg = "#5d9794", blend = 30 })
          api.set_hl(0, "WinBorderDark", { fg = "#5d9794", bg = "#c2dddc", blend = 30 })
          api.set_hl(0, "WinBorderTransparent", { bg = "#111a2c" })
          ]]
          api.set_hl(0, "WinBorderTop", { fg = palette.border })
          api.set_hl(0, "WinBorderLeft", { fg = palette.border })
          api.set_hl(0, "WinBorderRight", { fg = palette.border })
          api.set_hl(0, "WinBorderBottom", { fg = palette.border })
        end,
      })
    end,
    config = {
      open_mapping = false,
      direction = "float",
      float_opts = {
        border = {
          { "⣀", "WinBorderTop" },
          { "⣀", "WinBorderTop" },
          { "⣀", "WinBorderTop" },
          { "⢸", "WinBorderRight" },
          { "⠉", "WinBorderBottom" },
          { "⠉", "WinBorderBottom" },
          { "⠉", "WinBorderBottom" },
          { "⡇", "WinBorderLeft" },
        },
      },
      winbar = { enabled = true },
    },
  },

  { "cocopon/colorswatch.vim", cmd = { "ColorSwatchGenerate" } },

  { "cocopon/inspecthi.vim", cmd = { "Inspecthi", "InspecthiShowInspector", "InspecthiHideInspector" } },

  {
    "dhruvasagar/vim-table-mode",
    cmd = { "TableModeToggle" },
    keys = { { "`tm", [[<Cmd>TableModeToggle<CR>]] } },
    init = function()
      vim.g.table_mode_corner = "|"
    end,
  },

  { "dstein64/vim-startuptime", cmd = { "StartupTime" } },

  { "fuenor/JpFormat.vim", cmd = { "JpFormatAll", "JpJoinAll" } },

  { "lambdalisue/suda.vim", cmd = { "SudaRead", "SudaWrite" } },

  {
    "iberianpig/tig-explorer.vim",
    dependencies = { "rbgrouleff/bclose.vim" },
    -- TODO: cmd does not work?
    keys = {
      { "n", "<Leader>tT" },
      { "n", "<Leader>tt" },
      { "<Leader>tT", [[<Cmd>TigOpenCurrentFile<CR>]] },
      { "<Leader>tt", [[<Cmd>TigOpenProjectRootDir<CR>]] },
      { "<Leader>tg", [[<Cmd>TigGrep<CR>]] },
      { "<Leader>tr", [[<Cmd>TigGrepResume<CR>]] },
      { "<Leader>tG", [[y<Cmd>TigGrep<Space><C-R>"<CR>]], mode = { "v" } },
      { "<Leader>tc", [[<Cmd><C-u>:TigGrep<Space><C-R><C-W><CR>]] },
      { "<Leader>tb", [[<Cmd>TigBlame<CR>]] },
    },
    cmd = {
      "Tig",
      "TigOpenCurrentFile",
      "TigOpenProjectRootDir",
      "TigGrep",
      "TigBlame",
      "TigGrepResume",
      "TigStatus",
      "TigOpenFileWithCommit",
    },
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && yarn",
    init = function()
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_open_to_the_world = 1
    end,
  },

  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle" },
    keys = { { "<A-u>", [[<Cmd>UndotreeToggle<CR>]] } },
    init = function()
      vim.g.undotree_HelpLine = 0
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_TreeNodeShape = "●"
      vim.g.undotree_WindowLayout = 2
    end,
  },

  {
    "norcalli/nvim-colorizer.lua",
    keys = { { "<A-C>", [[<Cmd>ColorizerToggle<CR>]] } },
    cmd = {
      "ColorizerAttachToBuffer",
      "ColorizerDetachFromBuffer",
      "ColorizerReloadAllBuffers",
      "ColorizerToggle",
    },
  },

  {
    "npxbr/glow.nvim",
    cmd = { "Glow", "GlowInstall" },
    init = function()
      vim.g.glow_use_pager = true
    end,
  },

  { "powerman/vim-plugin-AnsiEsc", cmd = { "AnsiEsc" } },

  {
    "pwntester/octo.nvim",
    cmd = { "Octo" },
    keys = { { "<A-O>", ":Octo " } },
    config = { github_hostname = vim.g.gh_e_host },
  },

  {
    "rhysd/ghpr-blame.vim",
    cmd = { "GHPRBlame" },
    config = function()
      local settings = uv.os_homedir() .. "/.ghpr-blame.vim"
      if fn.filereadable(settings) == 1 then
        vim.cmd.source(settings)
        -- TODO: mappings for VV
        vim.g.ghpr_show_pr_mapping = "<A-g>"
        vim.g.ghpr_show_pr_in_message = 1
      else
        vim.notify("file not found: " .. settings, vim.log.levels.WARN)
      end
    end,
  },

  {
    "rhysd/git-messenger.vim",
    cmd = { "GitMessenger" },
    keys = { { "<A-b>", [[<Cmd>GitMessenger<CR>]] } },
    init = function()
      vim.g.git_messenger_no_default_mappings = true
    end,
  },

  {
    "tyru/capture.vim",
    dependencies = { { "thinca/vim-prettyprint", cmd = { "PP", "PrettyPrint" } } },
    cmd = { "Capture" },
  },

  {
    "tpope/vim-eunuch",
    cmd = {
      "Cfind",
      "Chmod",
      "Clocate",
      "Copy",
      "Delete",
      "Duplicate",
      "Lfind",
      "Llocate",
      "Mkdir",
      "Move",
      "Remove",
      "Rename",
      "SudoEdit",
      "SudoWrite",
      "Unlink",
      "W",
      "Wall",
    },
  },

  {
    "tyru/open-browser.vim",
    cmd = { "OpenBrowser", "OpenBrowserSearch" },
    keys = { { "g<CR>", [[<Plug>(openbrowser-smart-search)]], mode = { "n", "v" } } },
    fn = { "openbrowser#open" },
  },

  {
    "vifm/vifm.vim",
    cmd = { "EditVifm", "VsplitVifm", "SplitVifm", "DiffVifm", "TabVifm" },
    ft = { "vifm" },
  },

  {
    "vim-scripts/autodate.vim",
    cmd = { "Autodate", "AutodateOFF", "AutodateON" },
    init = function()
      vim.g.autodate_format = "%FT%T%z"
      local group = api.create_augroup("Autodate", {})
      api.create_autocmd({ "BufRead", "BufNewFile" }, {
        group = group,
        once = true,
        callback = function()
          api.create_autocmd({ "BufUnload", "FileWritePre", "BufWritePre" }, { group = group, command = "Autodate" })
        end,
      })
    end,
  },

  {
    "LumaKernel/nvim-visual-eof.lua",
    event = { "BufRead", "BufNewFile" },
    init = function()
      local palette = require "core.utils.palette" "nord"
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("nord_visual_eof", {}),
        pattern = "nord",
        callback = function()
          api.set_hl(0, "VisualEOL", { fg = palette.green })
          api.set_hl(0, "VisualNoEOL", { fg = palette.red })
        end,
      })
    end,
    config = {
      text_EOL = " ",
      text_NOEOL = " ",
      ft_ng = {
        "FTerm",
        "denite",
        "denite-filter",
        "fugitive.*",
        "git.*",
        "packer",
      },
      buf_filter = function(bufnr)
        return api.buf_get_option(bufnr, "buftype") == ""
      end,
    },
  },

  {
    "ahmedkhalf/project.nvim",
    event = { "BufRead", "BufNewFile" },
    config = {
      detection_methods = { "pattern" },
      patterns = { ".git" },
      show_hidden = true,
      silent_chdir = false,
    },
  },

  {
    "b0o/incline.nvim",
    event = { "FocusLost", "CursorHold" },
    config = true,
  },

  {
    "delphinus/auto-cursorline.nvim",
    event = { "BufRead", "CursorMoved", "CursorMovedI", "WinEnter", "WinLeave" },
    config = true,
  },

  {
    "delphinus/dwm.nvim",
    event = { "VimEnter" },
    keys = {
      { "<C-j>", "<C-w>w" },
      { "<C-k>", "<C-w>W" },
      { "<A-CR>", dwm "focus" },
      { "<C-@>", dwm "focus" },
      { "<C-Space>", dwm "focus" },
      { "<C-l>", dwm "grow" },
      { "<C-h>", dwm "shrink" },
      { "<C-n>", dwm "new" },
      { "<C-q>", dwm "rotateLeft" },
      { "<C-s>", dwm "rotate" },
      { "<C-c>", dwm "close" },
    },
    cond = function()
      -- HACK: Do not load when it is loading committia.vim
      local file = vim.fs.basename(api.buf_get_name(0))
      local not_to_load = { "COMMIT_EDITMSG", "MERGE_MSG" }
      for _, name in ipairs(not_to_load) do
        if file == name then
          return false
        end
      end
      return true
    end,
    config = {
      key_maps = false,
      master_pane_count = 1,
      master_pane_width = "60%",
    },
  },

  {
    "delphinus/emcl.nvim",
    event = { "CmdlineEnter" },
    config = true,
  },

  {
    "folke/noice.nvim",
    event = { "BufRead", "BufNewFile", "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "nvim-treesitter",
      { "MunifTanjim/nui.nvim" },
      {
        "rcarriga/nvim-notify",
        config = {
          render = "minimal",
          background_colour = require "core.utils.palette"("nord").black,
          level = "trace",
          on_open = function(win)
            api.win_set_config(win, { focusable = false })
          end,
        },
      },
    },
    init = function()
      local palette = require "core.utils.palette" "nord"

      -- HACK: avoid to set duplicatedly (ex. after PackerCompile)
      if not _G.__vim_notify_overwritten then
        vim.notify = function(...)
          local args = { ... }
          require "notify"
          require "noice"
          vim.schedule(function()
            vim.notify(unpack(args))
          end)
        end
        _G.__vim_notify_overwritten = true
      end

      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("noice-colors", {}),
        pattern = "nord",
        callback = function()
          api.set_hl(0, "NoiceLspProgressSpinner", { fg = palette.white })
          api.set_hl(0, "NoiceLspProgressTitle", { fg = palette.orange })
          api.set_hl(0, "NoiceLspProgressClient", { fg = palette.yellow })
        end,
      })
    end,
    config = function()
      require("noice").setup {
        cmdline = {
          format = {
            cmdline = { icon = "" },
            search_down = { icon = "" },
            search_up = { icon = "" },
            filter = { icon = "" },
          },
        },
        popupmenu = {
          --backend = "cmp",
          backend = "nui",
        },
        lsp = {
          hover = {
            enabled = true,
          },
          signature = {
            enabled = true,
          },
        },
        format = {
          spinner = {
            name = "dots12",
            --name = "sand",
          },
        },
      }

      require("modules.start.config.lualine").is_noice_available = true
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = { "BufRead", "FocusLost", "CursorHold" },
    config = {
      keywords = {
        FIX = { icon = "", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = "", color = "info" },
        HACK = { icon = "", color = "warning" },
        WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = "", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = "", color = "hint", alt = { "INFO" } },
        TEST = { icon = "", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
  },

  {
    "haringsrob/nvim_context_vt",
    event = { "BufNewFile", "BufRead", "FocusLost", "CursorHold" },
    wants = { "nvim-treesitter" },
    config = function()
      local palette = require "core.utils.palette" "nord"
      api.set_hl(0, "ContextVt", { fg = palette.context })
      require("nvim_context_vt").setup {
        prefix = "󾪜",
        highlight = "ContextVt",
      }
    end,
  },

  {
    "itchyny/vim-cursorword",
    event = { "FocusLost", "CursorHold" },
    init = function()
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("cursorword-colors", {}),
        pattern = "nord",
        callback = function()
          api.set_hl(0, "CursorWord", { undercurl = true })
        end,
      })
    end,
  },

  {
    "itchyny/vim-parenmatch",
    event = { "FocusLost", "CursorHold" },
    init = function()
      vim.g.loaded_matchparen = 1
    end,
    config = function()
      fn["parenmatch#highlight"]()
    end,
  },

  {
    "lewis6991/foldsigns.nvim",
    event = { "FocusLost", "CursorHold" },
    config = true,
  },

  {
    "lewis6991/gitsigns.nvim",
    cmd = { "Gitsigns" },
    event = { "FocusLost", "CursorHold" },
    keys = {
      {
        "gL",
        function()
          require("gitsigns").setloclist()
        end,
      },
      {
        "gQ",
        function()
          require("gitsigns").setqflist "all"
        end,
      },
    },
    init = function()
      local palette = require "core.utils.palette" "nord"
      api.set_hl(0, "GitSignsAdd", { fg = palette.green })
      api.set_hl(0, "GitSignsChange", { fg = palette.yellow })
      api.set_hl(0, "GitSignsDelete", { fg = palette.red })
      api.set_hl(0, "GitSignsCurrentLineBlame", { fg = palette.brighter_black })
      api.set_hl(0, "GitSignsAddInline", { bg = palette.bg_green })
      api.set_hl(0, "GitSignsChangeInline", { bg = palette.bg_yellow })
      api.set_hl(0, "GitSignsDeleteInline", { bg = palette.bg_red })
      api.set_hl(0, "GitSignsUntracked", { fg = palette.magenta })
    end,
    config = function()
      local gitsigns = require "gitsigns"
      local function gs(method)
        return function()
          gitsigns[method]()
        end
      end

      gitsigns.setup {
        signs = {
          add = { hl = "GitSignsAdd" },
          change = { hl = "GitSignsChange" },
          delete = { hl = "GitSignsDelete", text = "✗" },
          topdelete = { hl = "GitSignsDelete", text = "↑" },
          changedelete = { hl = "GitSignsChange", text = "•" },
          untracked = { hl = "GitSignsUntracked", text = "⢸" },
        },
        numhl = true,
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 10,
        },
        word_diff = true,
        on_attach = function(bufnr)
          local km = vim.keymap
          km.set("n", "]c", gs "next_hunk", { buffer = bufnr })
          km.set("n", "[c", gs "prev_hunk", { buffer = bufnr })
        end,
      }

      -- setup nvim-scrollbar
      require("scrollbar.handlers.gitsigns").setup {}
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "FocusLost", "CursorHold" },
    init = function()
      -- │┃┊┋┆┇║⡇⢸
      vim.g.indent_blankline_char = "│"
      vim.g.indent_blankline_space_char = "∙"
      vim.g.indent_blankline_show_current_context = true
      vim.g.indent_blankline_use_treesitter = true
      vim.g.indent_blankline_show_end_of_line = true
      vim.g.indent_blankline_show_foldtext = false
      vim.g.indent_blankline_filetype_exclude = { "help", "packer", "FTerm" }
    end,
  },

  {
    "lukas-reineke/virt-column.nvim",
    event = { "FocusLost", "CursorHold" },
    config = function()
      local palette = require "core.utils.palette" "nord"
      api.set_hl(0, "ColorColumn", { bg = "NONE" })
      api.set_hl(0, "VirtColumn", { fg = palette.brighter_black })
      local vt = require "virt-column"
      vt.setup { char = "⡂" }
      api.create_autocmd("TermEnter", {
        callback = function()
          vt.clear_buf(0)
        end,
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = { "InsertEnter", "CursorHold", "FocusLost", "BufRead", "BufNewFile" },
    dependencies = {
      --{ "kyazdani42/nvim-web-devicons", opt = true },
      { "delphinus/nvim-web-devicons", branch = "feature/sfmono-square" },
      { "delphinus/eaw.nvim" },
    },
    init = function()
      vim.opt.laststatus = 0
      vim.opt.showtabline = 0
    end,
    config = function()
      require("modules.start.config.lualine"):config()
    end,
  },

  {
    "petertriho/nvim-scrollbar",
    event = {
      "BufWinEnter",
      "CmdwinLeave",
      "TabEnter",
      "TermEnter",
      "TextChanged",
      "VimResized",
      "WinEnter",
      "WinScrolled",
    },
    config = {
      marks = {
        GitAdd = {
          text = "⢸",
        },
        GitChange = {
          text = "⢸",
        },
      },
    },
  },

  {
    "tpope/vim-fugitive",
    keys = {
      { "git", [[<Cmd>Git<CR>]] },
      { "g<Space>", [[:Git ]] },
      { "d<", [[<Cmd>diffget //2<CR>]] },
      { "d>", [[<Cmd>diffget //3<CR>]] },
      { "gs", [[<Cmd>Gstatus<CR>]] },
    },
    event = { "BufRead", "FocusLost", "CursorHold" },
  },

  { "dix75/jira.vim", ft = { "confluencewiki" } },
  { "Glench/Vim-Jinja2-Syntax", ft = { "jinja" } },
  { "Vimjas/vim-python-pep8-indent", ft = { "python" } },
  { "aklt/plantuml-syntax", ft = { "plantuml" } },
  { "aliou/bats.vim", ft = { "bats" } },
  -- {'dag/vim-fish' ft = {'fish'}},
  { "blankname/vim-fish", ft = { "fish" } },
  { "c9s/perlomni.vim", ft = { "perl" } },
  { "delphinus/qfheight.nvim", ft = { "qf" }, config = true },
  { "delphinus/vim-data-section-simple", ft = { "perl" } },
  { "delphinus/vim-firestore", ft = { "firestore" } },
  { "hail2u/vim-css3-syntax", ft = { "css" } },
  { "isobit/vim-caddyfile", ft = { "caddyfile" } },
  { "junegunn/vader.vim", ft = { "vader" } },
  { "kchmck/vim-coffee-script", ft = { "coffee" } },

  {
    "kevinhwang91/nvim-bqf",
    ft = { "qf" },
    init = function()
      api.set_hl(0, "BqfPreviewRange", { link = "Underlined" })
    end,
  },

  { "leafo/moonscript-vim", ft = { "moonscript" } },
  { "moznion/vim-cpanfile", ft = { "cpanfile" } },

  {
    "motemen/vim-syntax-hatena",
    ft = { "hatena" },
    config = function()
      vim.g.hatena_syntax_html = true
    end,
  },

  { "motemen/xslate-vim", ft = { "xslate" } },
  { "msanders/cocoa.vim", ft = { "objc" } },
  { "mustache/vim-mustache-handlebars", ft = { "mustache", "handlebars", "html.mustache", "html.handlebars" } },
  { "nikvdp/ejs-syntax", ft = { "ejs" } },
  { "pboettch/vim-cmake-syntax", ft = { "cmake" } },

  {
    "pearofducks/ansible-vim",
    ft = { "ansible", "yaml.ansible" },
    config = function()
      vim.g.ansible_name_highlight = "b"
      vim.g.ansible_extra_keywords_highlight = 1
    end,
  },

  { "rhysd/vim-textobj-ruby", requires = { { "kana/vim-textobj-user" } }, ft = { "ruby" } },

  {
    "rhysd/committia.vim",
    ft = { "gitcommit" },
    init = function()
      vim.g.committia_hooks = {
        edit_open = function(info)
          if info.vcs == "git" and fn.getline(1) == "" then
            vim.cmd.startinsert()
          end
          vim.keymap.set("i", "<A-d>", [[<Plug>(committia-scroll-diff-down-half)]], { buffer = true })
          vim.keymap.set("i", "<A-∂>", [[<Plug>(committia-scroll-diff-down-half)]], { buffer = true })
          vim.keymap.set("i", "<A-u>", [[<Plug>(committia-scroll-diff-up-half)]], { buffer = true })
        end,
      }
    end,
  },

  { "delphinus/vim-rails", branch = "feature/recognize-ridgepole", ft = { "ruby" } },

  {
    "vim-perl/vim-perl",
    ft = { "perl", "perl6" },
    init = function()
      vim.g.perl_include_pod = 1
      vim.g.perl_string_as_statement = 1
      vim.g.perl_sync_dist = 1000
      vim.g.perl_fold = 1
      vim.g.perl_nofold_packages = 1
      vim.g.perl_fold_anonymous_subs = 1
      vim.g.perl_sub_signatures = 1
    end,
  },

  { "vim-scripts/a.vim", ft = { "c", "cpp" } },
  { "vim-scripts/applescript.vim", ft = { "applescript" } },
  { "vim-scripts/fontforge_script.vim", ft = { "fontforge_script" } },
  { "vim-scripts/nginx.vim", ft = { "nginx" } },
  { "vim-skk/skkdict.vim", ft = { "skkdict" } },

  {
    "arecarn/vim-fold-cycle",
    keys = {
      { "<A-l>", [[<Plug>(fold-cycle-open)]] },
      { "<A-¬>", [[<Plug>(fold-cycle-open)]] },
      { "<A-h>", [[<Plug>(fold-cycle-open)]] },
      { "<A-˙>", [[<Plug>(fold-cycle-open)]] },
    },
    init = function()
      vim.g.fold_cycle_default_mapping = 0
    end,
  },

  {
    "chikatoike/concealedyank.vim",
    keys = { { "Y", "<Plug>(operator-concealedyank)", mode = { "x" } } },
  },

  { "delphinus/vim-tmux-copy", keys = { "<A-[>", "<A-“>" } },

  {
    "inkarkat/vim-LineJuggler",
    dependencies = {
      { "inkarkat/vim-ingo-library" },
      { "tpope/vim-repeat" },
      { "vim-scripts/visualrepeat" },
    },
    keys = {
      "[d",
      "]d",
      "[E",
      "]E",
      "[e",
      "]e",
      "[f",
      "]f",
      "[<Space>",
      "]<Space>",
    },
  },

  {
    "junegunn/vim-easy-align",
    keys = { { "<CR>", "<Plug>(EasyAlign)", mode = { "v" } } },
    init = function()
      vim.g.easy_align_delimiters = {
        [">"] = { pattern = [[>>\|=>\|>]] },
        ["/"] = { pattern = [[//\+\|/\*\|\*/]], ignore_groups = { "String" } },
        ["#"] = {
          pattern = [[#\+]],
          ignore_groups = { "String" },
          delimiter_align = "l",
        },
        ["]"] = {
          pattern = [=[[[\]]]=],
          left_margin = 0,
          right_margin = 0,
          stick_to_left = 0,
        },
        [")"] = {
          pattern = "[()]",
          left_margin = 0,
          right_margin = 0,
          stick_to_left = 0,
        },
        ["d"] = {
          pattern = [[ \(\S\+\s*[;=]\)\@=]],
          left_margin = 0,
          right_margin = 0,
        },
      }
    end,
  },

  {
    "kylechui/nvim-surround",
    keys = { "ys", "ds", "cs", "S" },
    config = true,
  },

  {
    "phaazon/hop.nvim",
    keys = {
      { "n", [['j]] },
      { "v", [['j]] },
      { "n", [['k]] },
      { "v", [['k]] },
    },
    config = function()
      local hop = require "hop"
      local palette = require "core.utils.palette" "nord"
      hop.setup {
        keys = "hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB",
        extend_visual = true,
      }
      local direction = require("hop.hint").HintDirection
      vim.keymap.set({ "n", "v" }, [['j]], function()
        if fn.getcmdwintype() == "" then
          hop.hint_lines { direction = direction.AFTER_CURSOR }
        end
      end)
      vim.keymap.set({ "n", "v" }, [['k]], function()
        if fn.getcmdwintype() == "" then
          hop.hint_lines { direction = direction.BEFORE_CURSOR }
        end
      end)
      if vim.opt.background:get() == "dark" then
        api.set_hl(0, "HopNextKey", { fg = palette.orange, bold = true })
        api.set_hl(0, "HopNextKey1", { fg = palette.cyan, bold = true })
        api.set_hl(0, "HopNextKey2", { fg = palette.dark_white })
        api.set_hl(0, "HopUnmatched", { fg = palette.gray })
      end
    end,
  },

  {
    "ruifm/gitlinker.nvim",
    keys = { { "gc", mode = { "n", "v" } } },
    dependencies = { "plenary.nvim" },
    config = {
      opts = {
        add_current_line_on_normal_mode = false,
        action_callback = function(url)
          local actions = require "gitlinker.actions"
          actions.copy_to_clipboard(url)
          actions.open_in_browser(url)
        end,
      },
      callbacks = {
        [vim.g.gh_e_host] = function(url_data)
          return require("gitlinker.hosts").get_github_type_url(url_data)
        end,
      },
      mappings = "gc",
    },
  },

  {
    "t9md/vim-quickhl",
    keys = {
      { "<Space>m", [[<Plug>(quickhl-manual-this)]], mode = { "n", "x" } },
      { "<Space>t", [[<Plug>(quickhl-manual-toggle)]], mode = { "n", "x" } },
      { "<Space>M", [[<Plug>(quickhl-manual-reset)]], mode = { "n", "x" } },
    },
  },

  {
    "thinca/vim-visualstar",
    keys = { { "*", [[<Plug>(visualstar-*)]], mode = { "x" } } },
    init = function()
      vim.g.visualstar_no_default_key_mappings = 1
    end,
  },

  {
    "tyru/columnskip.vim",
    keys = {
      { "[j", [[<Plug>(columnskip:nonblank:next)]], mode = { "n", "x", "o" } },
      { "[k", [[<Plug>(columnskip:nonblank:prev)]], mode = { "n", "x", "o" } },
      { "]j", [[<Plug>(columnskip:first-nonblank:next)]], mode = { "n", "x", "o" } },
      { "]k", [[<Plug>(columnskip:first-nonblank:prev)]], mode = { "n", "x", "o" } },
    },
  },

  {
    "hrsh7th/vim-searchx",
    fn = { "searchx#*" },
    init = function()
      local km = vim.keymap
      local searchx = function(name)
        return function(opt)
          return function()
            local f = fn["searchx#" .. name]
            return opt and f(opt) or f()
          end
        end
      end

      -- Overwrite / and ?.
      km.set({ "n", "x" }, "?", searchx "start" { dir = 0 })
      km.set({ "n", "x" }, "/", searchx "start" { dir = 1 })
      km.set("c", "<A-;>", searchx "select"())

      -- Move to next/prev match.
      km.set({ "n", "x" }, "N", searchx "prev"())
      km.set({ "n", "x" }, "n", searchx "next"())
      km.set({ "c", "n", "x" }, "<A-z>", searchx "prev"())
      km.set({ "c", "n", "x" }, "<A-x>", searchx "next"())

      -- Clear highlights
      km.set("n", "<Esc><Esc>", searchx "clear"())
    end,
    config = function()
      vim.g.searchx = {
        -- Auto jump if the recent input matches to any marker.
        auto_accept = true,
        -- The scrolloff value for moving to next/prev.
        scrolloff = vim.opt.scrolloff:get(),
        -- To enable scrolling animation.
        scrolltime = 0,
        -- Marker characters.
        markers = vim.split("HJKLASDFGYUIOPQWERTNMZXCVB", ""),
        -- To enable auto nohlsearch after cursor is moved
        nohlsearch = { jump = true },

        convert = function(input)
          -- If the input does not contain iskeyword characters, it deals with
          -- the input as "very magic".
          if not vim.regex([[\k]]):match_str(input) then
            return [[\V]] .. input
          elseif not input:match "^%." then
            -- If the input contains spaces, it tries fuzzy matching.
            return input:sub(1, 1) .. fn.substitute(input:sub(2), [[\\\@<! ]], [[.\\{-}]], "g")
          end
          -- If the input has `.` at the beginning, it converts the input with
          -- cmigemo.
          local Path = require "plenary.path"
          local dict = Path.new(vim.env.HOMEBREW_PREFIX, "opt/cmigemo/share/migemo/utf-8/migemo-dict")
          if not dict:exists() then
            vim.notify("Cannot find cmigemo to be installed. Run `brew install cmigemo`.", vim.log.levels.WARN)
            return input
          end
          local re
          require("plenary.job")
            :new({
              command = "cmigemo",
              args = { "-v", "-d", dict.filename, "-w", input:sub(2) },
              on_exit = function(j, return_val)
                local out = j:result()
                if return_val == 0 and #out > 0 then
                  re = out[1]
                else
                  vim.notify("cmigemo execution failed", vim.log.levels.WARN)
                  re = input:sub(2)
                end
              end,
            })
            :sync()
          return re
        end,
      }

      api.set_hl(0, "SearchxMarker", { link = "DiffChange" })
      api.set_hl(0, "SearchxMarkerCurrent", { link = "WarningMsg" })
    end,
  },

  { "delphinus/characterize.nvim", config = true },
  { "delphinus/f_meta.nvim" },
  { "delphinus/lazy_require.nvim" },
  { "nvim-lua/plenary.nvim" },
}
