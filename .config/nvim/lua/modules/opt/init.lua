local fn, uv, api = require("core.utils").globals()
local config = require "modules.opt.config"

return {
  --{'wbthomason/packer.nvim', opt = true},
  { "delphinus/packer.nvim", branch = "feature/denops", opt = true },
  { "vim-denops/denops.vim", opt = true },

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
  { "cocopon/colorswatch.vim", cmd = { "ColorSwatchGenerate" } },

  { "cocopon/inspecthi.vim", cmd = { "Inspecthi", "InspecthiShowInspector", "InspecthiHideInspector" } },

  { "dhruvasagar/vim-table-mode", cmd = { "TableModeToggle" }, setup = config.table_mode.setup },

  { "fuenor/JpFormat.vim", cmd = { "JpFormatAll", "JpJoinAll" } },

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
    "tyru/open-browser.vim",
    cmd = { "OpenBrowser", "OpenBrowserSearch" },
    keys = { "<Plug>(openbrowser-smart-search)" },
    fn = { "openbrowser#open" },
    setup = function()
      vim.keymap.set({ "n", "v" }, "g<CR>", [[<Plug>(openbrowser-smart-search)]])
    end,
  },

  { "tweekmonster/startuptime.vim", cmd = { "StartupTime" } },

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
    "b0o/incline.nvim",
    event = { "FocusLost", "CursorHold" },
    config = function()
      require("incline").setup {}
    end,
  },

  {
    "delphinus/auto-cursorline.nvim",
    event = { "BufRead", "CursorMoved", "CursorMovedI", "WinEnter", "WinLeave" },
    config = function()
      require("auto-cursorline").setup {}
    end,
  },

  {
    "delphinus/dwm.nvim",
    event = { "VimEnter" },
    cond = config.dwm.cond,
    config = config.dwm.config,
  },

  {
    "delphinus/emcl.nvim",
    event = { "CmdlineEnter" },
    config = function()
      require("emcl").setup {}
    end,
  },

  {
    "haringsrob/nvim_context_vt",
    event = { "BufNewFile", "BufRead", "FocusLost", "CursorHold" },
    wants = { "nvim-treesitter" },
    config = config.context_vt,
  },

  { "itchyny/vim-cursorword", event = { "FocusLost", "CursorHold" } },

  {
    "itchyny/vim-parenmatch",
    event = { "FocusLost", "CursorHold" },
    setup = [[vim.g.loaded_matchparen = 1]],
    config = [[fn['parenmatch#highlight']()]],
  },

  {
    "lewis6991/foldsigns.nvim",
    event = { "FocusLost", "CursorHold" },
    config = function()
      require("foldsigns").setup {}
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "FocusLost", "CursorHold" },
    config = config.gitsign,
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
    setup = config.scrollbar.setup,
    config = config.scrollbar.config,
  },
  -- }}}

  -- ft {{{
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
  { "kchmck/vim-coffee-script", ft = { "coffee" }, setup = config.coffee_script.setup },
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
      { "inkarkat/vim-ingo-library" },
      { "vim-repeat" },
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

  { "junegunn/vim-easy-align", keys = { { "v", "<Plug>(EasyAlign)" } }, setup = config.easy_align.setup },

  {
    "kylechui/nvim-surround",
    keys = {
      { "n", "ys" },
      { "n", "ds" },
      { "n", "cs" },
      { "v", "S" },
    },
    config = function()
      require("nvim-surround").setup {}
    end,
  },

  {
    "phaazon/hop.nvim",
    --"delphinus/hop.nvim",
    --branch = "feature/migemo",
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
    requires = { "nvim-lua/plenary.nvim" },
    config = config.gitlinker,
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
  { "sainnhe/artify.vim", fn = { "artify#convert" } },
  { "vim-jp/vital.vim", fn = { "vital#vital#new" } },

  { "hrsh7th/vim-searchx", fn = { "searchx#*" }, setup = config.searchx.setup, config = config.searchx.config },
  -- }}}

  -- module {{{
  { "numToStr/FTerm.nvim", module = { "FTerm" }, setup = config.fterm.setup, config = config.fterm.config },
  -- }}}
}

-- vim:se fdm=marker:
