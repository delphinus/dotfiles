local config = require "modules.opt.config"
local lazy_require = require "lazy_require"

return {
  --{'wbthomason/packer.nvim', opt = true},
  { "delphinus/packer.nvim", branch = "feature/denops", opt = true },
  { "vim-denops/denops.vim", event = { "CursorHold", "FocusLost" } },

  -- Colorscheme {{{
  {
    --"arcticicestudio/nord-vim",
    "delphinus/nord-nvim",
    run = config.nord.run,
    config = config.nord.config,
  },

  { "lifepillar/vim-solarized8", opt = true },
  -- }}}

  -- cmd {{{
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "ToggleTermAll", "TermExec" },
    setup = config.toggleterm.setup,
    config = lazy_require("toggleterm").setup {
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

  { "dhruvasagar/vim-table-mode", cmd = { "TableModeToggle" }, setup = config.table_mode.setup },

  { "dstein64/vim-startuptime", cmd = { "StartupTime" } },

  { "fuenor/JpFormat.vim", cmd = { "JpFormatAll", "JpJoinAll" } },

  { "lambdalisue/suda.vim", cmd = { "SudaRead", "SudaWrite" } },

  {
    "rbgrouleff/bclose.vim",
    -- TODO: cmd does not work?
    keys = {
      { "n", "<Leader>tT" },
      { "n", "<Leader>tt" },
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
    "iberianpig/tig-explorer.vim",
    after = { "bclose.vim" },
    -- TODO: cmd does not work?
    keys = {
      { "n", "<Leader>tT" },
      { "n", "<Leader>tt" },
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
    config = config.tig_explorer,
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    setup = config.markdown_preview.setup,
    run = "cd app && yarn",
  },

  { "mbbill/undotree", cmd = { "UndotreeToggle" }, setup = config.undotree.setup },

  {
    "norcalli/nvim-colorizer.lua",
    cmd = {
      "ColorizerAttachToBuffer",
      "ColorizerDetachFromBuffer",
      "ColorizerReloadAllBuffers",
      "ColorizerToggle",
    },
    setup = config.colorizer.setup,
  },

  {
    "npxbr/glow.nvim",
    cmd = { "Glow", "GlowInstall" },
    setup = function()
      vim.g.glow_use_pager = true
    end,
  },

  { "powerman/vim-plugin-AnsiEsc", cmd = { "AnsiEsc" } },

  {
    "pwntester/octo.nvim",
    cmd = { "Octo" },
    key = {
      { "n", "<A-O>" },
    },
    setup = function()
      vim.keymap.set("n", "<A-O>", "Octo ")
    end,
    config = function()
      require("octo").setup { github_hostname = vim.g.gh_e_host }
    end,
  },

  {
    "rhysd/ghpr-blame.vim",
    cmd = { "GHPRBlame" },
    config = config.ghpr_blame,
  },

  { "rhysd/git-messenger.vim", cmd = { "GitMessenger" }, setup = config.git_messenger.setup },

  {
    "tyru/capture.vim",
    requires = {
      { "thinca/vim-prettyprint", cmd = { "PP", "PrettyPrint" } },
    },
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
    config = config.eunuch,
  },

  {
    "tyru/open-browser.vim",
    cmd = { "OpenBrowser", "OpenBrowserSearch" },
    keys = { "<Plug>(openbrowser-smart-search)" },
    fn = { "openbrowser#open" },
    setup = function()
      vim.keymap.set({ "n", "v" }, "g<CR>", [[<Plug>(openbrowser-smart-search)]])
    end,
  },

  {
    "vifm/vifm.vim",
    cmd = { "EditVifm", "VsplitVifm", "SplitVifm", "DiffVifm", "TabVifm" },
    ft = { "vifm" },
  },

  {
    "vim-scripts/autodate.vim",
    cmd = { "Autodate", "AutodateOFF", "AutodateON" },
    setup = config.autodate.setup,
  },
  -- }}}

  -- event {{{
  {
    "ahmedkhalf/project.nvim",
    event = { "BufRead", "BufNewFile" },
    config = lazy_require("project_nvim").setup {
      ignore_lsp = { "bashls", "null-ls", "tsserver", "dockerls" },
      patterns = { ".git" },
      show_hidden = true,
    },
  },

  {
    "b0o/incline.nvim",
    event = { "FocusLost", "CursorHold" },
    config = lazy_require("incline").setup {},
  },

  {
    "delphinus/auto-cursorline.nvim",
    event = { "BufRead", "CursorMoved", "CursorMovedI", "WinEnter", "WinLeave" },
    config = lazy_require("auto-cursorline").setup {},
  },

  {
    "delphinus/dwm.nvim",
    event = { "VimEnter" },
    cond = config.dwm.cond,
    config = config.dwm.config,
  },

  {
    "delphinus/emcl.nvim",
    branch = "feature/setcmdline",
    event = { "CmdlineEnter" },
    config = lazy_require("emcl").setup {},
  },

  { "delphinus/vim-quickfix-height", events = { "BufRead", "FocusLost", "CursorHold" } },

  {
    "folke/noice.nvim",
    event = { "BufRead", "BufNewFile", "InsertEnter", "CmdlineEnter" },
    module = { "noice" },
    requires = {
      { "MunifTanjim/nui.nvim" },
      {
        "rcarriga/nvim-notify",
        module = { "notify" },
        config = lazy_require("notify").setup {
          render = "minimal",
          background_colour = require "core.utils.palette"("nord").black,
          level = "trace",
          on_open = function(win)
            api.win_set_config(win, { focusable = false })
          end,
        },
      },
    },
    wants = { "nvim-treesitter" },
    setup = config.noice.setup,
    config = config.noice.config,
  },

  {
    "folke/todo-comments.nvim",
    events = { "BufRead", "FocusLost", "CursorHold" },
    config = lazy_require("todo-comments").setup {
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
    config = config.context_vt,
  },

  { "itchyny/vim-cursorword", event = { "FocusLost", "CursorHold" }, setup = config.cursorword.setup },

  {
    "itchyny/vim-parenmatch",
    event = { "FocusLost", "CursorHold" },
    setup = [[vim.g.loaded_matchparen = 1]],
    config = [[fn['parenmatch#highlight']()]],
  },

  {
    "lewis6991/foldsigns.nvim",
    event = { "FocusLost", "CursorHold" },
    config = lazy_require("foldsigns").setup {},
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "FocusLost", "CursorHold" },
    setup = config.gitsign.setup,
    config = config.gitsign.config,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "FocusLost", "CursorHold" },
    setup = config.indent_blankline.setup,
  },

  {
    "lukas-reineke/virt-column.nvim",
    event = { "FocusLost", "CursorHold" },
    config = config.virt_column,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = { "InsertEnter", "CursorHold", "FocusLost", "BufRead", "BufNewFile" },
    requires = {
      --{ "kyazdani42/nvim-web-devicons", opt = true },
      { "delphinus/nvim-web-devicons", branch = "feature/sfmono-square", module = { "nvim-web-devicons" } },
      { "delphinus/eaw.nvim", module = { "eaw" } },
    },
    setup = config.lualine.setup,
    config = config.lualine.config,
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
    config = lazy_require("scrollbar").setup {
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
    event = { "BufRead", "FocusLost", "CursorHold" },
    config = config.fugitive,
  },
  -- }}}

  -- ft {{{
  { "dix75/jira.vim", ft = { "confluencewiki" } },
  { "Glench/Vim-Jinja2-Syntax", ft = { "jinja" } },
  { "Vimjas/vim-python-pep8-indent", ft = { "python" } },
  { "aklt/plantuml-syntax", ft = { "plantuml" } },
  { "aliou/bats.vim", ft = { "bats" } },
  -- {'dag/vim-fish' ft = {'fish'}},
  { "blankname/vim-fish", ft = { "fish" } },
  { "c9s/perlomni.vim", ft = { "perl" } },
  { "delphinus/vim-data-section-simple", ft = { "perl" } },
  { "delphinus/vim-firestore", ft = { "firestore" } },
  { "hail2u/vim-css3-syntax", ft = { "css" } },
  { "isobit/vim-caddyfile", ft = { "caddyfile" } },
  { "junegunn/vader.vim", ft = { "vader" } },
  { "kchmck/vim-coffee-script", ft = { "coffee" } },
  { "kevinhwang91/nvim-bqf", ft = { "qf" } },
  { "leafo/moonscript-vim", ft = { "moonscript" } },
  { "moznion/vim-cpanfile", ft = { "cpanfile" } },
  { "motemen/vim-syntax-hatena", ft = { "hatena" }, config = [[vim.g.hatena_syntax_html = true]] },
  { "motemen/xslate-vim", ft = { "xslate" } },
  { "msanders/cocoa.vim", ft = { "objc" } },
  { "mustache/vim-mustache-handlebars", ft = { "mustache", "handlebars", "html.mustache", "html.handlebars" } },
  { "nikvdp/ejs-syntax", ft = { "ejs" } },
  { "pboettch/vim-cmake-syntax", ft = { "cmake" } },
  { "pearofducks/ansible-vim", ft = { "ansible", "yaml.ansible" }, config = config.ansible },
  { "rhysd/vim-textobj-ruby", requires = { { "kana/vim-textobj-user" } }, ft = { "ruby" } },
  { "rhysd/committia.vim", ft = { "gitcommit" }, setup = config.committia.setup },
  { "delphinus/vim-rails", branch = "feature/recognize-ridgepole", ft = { "ruby" } },
  { "vim-perl/vim-perl", ft = { "perl", "perl6" }, setup = config.perl.setup },
  { "vim-scripts/a.vim", ft = { "c", "cpp" } },
  { "vim-scripts/applescript.vim", ft = { "applescript" } },
  { "vim-scripts/fontforge_script.vim", ft = { "fontforge_script" } },
  { "vim-scripts/nginx.vim", ft = { "nginx" } },
  { "vim-skk/skkdict.vim", ft = { "skkdict" } },
  -- }}}

  -- keys {{{
  { "arecarn/vim-fold-cycle", keys = { { "n", "<Plug>(fold-cycle-" } }, setup = config.fold_cycle.setup },

  {
    "chikatoike/concealedyank.vim",
    keys = { { "x", "<Plug>(operator-concealedyank)" } },
    setup = function()
      vim.keymap.set("x", "Y", [[<Plug>(operator-concealedyank)]])
    end,
  },

  -- Add a space in the closing paren to enable to use folding
  { "delphinus/vim-tmux-copy", keys = { { "n", "<A-[>" }, { "n", "<A-“>" } } },

  {
    "inkarkat/vim-LineJuggler",
    requires = {
      { "inkarkat/vim-ingo-library", opt = true },
      { "tpope/vim-repeat", opt = true },
      { "vim-scripts/visualrepeat", opt = true },
    },
    wants = { "vim-ingo-library", "vim-repeat", "visualrepeat" },
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

  { "junegunn/vim-easy-align", keys = { { "v", "<Plug>(EasyAlign)" } }, setup = config.easy_align.setup },

  {
    "kylechui/nvim-surround",
    keys = {
      { "n", "ys" },
      { "n", "ds" },
      { "n", "cs" },
      { "v", "S" },
    },
    config = lazy_require("nvim-surround").setup {},
  },

  {
    "phaazon/hop.nvim",
    keys = {
      { "n", [['j]] },
      { "v", [['j]] },
      { "n", [['k]] },
      { "v", [['k]] },
    },
    config = config.hop,
  },

  {
    "ruifm/gitlinker.nvim",
    keys = {
      { "n", "gc" },
      { "v", "gc" },
    },
    wants = { "plenary.nvim" },
    config = lazy_require("gitlinker").setup {
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
      { "n", "<Plug>(quickhl-" },
      { "x", "<Plug>(quickhl-" },
    },
    setup = config.quickhl.setup,
  },

  { "thinca/vim-visualstar", keys = { { "x", "<Plug>(visualstar-" } }, setup = config.visualstar.setup },

  {
    "tyru/columnskip.vim",
    keys = { { "n", "<Plug>(columnskip:" }, { "x", "<Plug>(columnskip:" }, { "o", "<Plug>(columnskip:" } },
    setup = config.columnskip.setup,
  },
  -- }}}

  -- func {{{
  { "hrsh7th/vim-searchx", fn = { "searchx#*" }, setup = config.searchx.setup, config = config.searchx.config },
  -- }}}

  -- module {{{
  {
    "delphinus/characterize.nvim",
    module = { "characterize" },
    config = lazy_require("characterize").setup {},
  },

  { "delphinus/f_meta.nvim", module = { "f_meta" } },

  { "delphinus/lazy_require.nvim", module = { "lazy_require" } },

  { "nvim-lua/plenary.nvim", module_pattern = { "plenary.*" } },

  -- }}}
}

-- vim:se fdm=marker:
