local fn, uv, api = require("core.utils").globals()
local lazy_require = require "lazy_require"
local palette = require "core.utils.palette"

local function dwm(method)
  return function()
    require("dwm")[method]()
  end
end

return {
  {
    --"arcticicestudio/nord-vim",
    "delphinus/nord-nvim",
    branch = "feature/semantic-token",
    build = lazy_require("nord").update {
      italic = true,
      uniform_status_lines = true,
      uniform_diff_background = true,
      cursor_line_number_background = true,
      language_specific_highlights = false,
    },
    config = function()
      palette "nord" {
        nord = function(colors)
          api.set_hl(0, "Comment", { fg = colors.comment, italic = true })
          api.set_hl(0, "Delimiter", { fg = colors.blue })
          api.set_hl(0, "Constant", { fg = colors.dark_white, italic = true })
          api.set_hl(0, "Folded", { fg = colors.comment })
          api.set_hl(0, "Identifier", { fg = colors.bright_cyan })
          api.set_hl(0, "Special", { fg = colors.orange })
          api.set_hl(0, "Title", { fg = colors.cyan, bold = true })
          api.set_hl(0, "PmenuSel", { blend = 0 })
          api.set_hl(0, "NormalFloat", { fg = colors.dark_white, bg = colors.dark_black, blend = 10 })
          api.set_hl(0, "FloatBorder", { fg = colors.bright_cyan, bg = colors.dark_black, blend = 10 })
        end,
      }
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
      palette "toggleterm" {
        nord = function(colors)
          api.set_hl(0, "WinBorderTop", { fg = colors.border })
          api.set_hl(0, "WinBorderLeft", { fg = colors.border })
          api.set_hl(0, "WinBorderRight", { fg = colors.border })
          api.set_hl(0, "WinBorderBottom", { fg = colors.border })
        end,
      }
    end,
    opts = {
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
    init = function()
      vim.g.table_mode_map_prefix = "`t"
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
    opts = function()
      return { github_hostname = vim.g.GITHUB_ENTERPRISE_HOST }
    end,
  },

  {
    "rhysd/ghpr-blame.vim",
    cmd = { "GHPRBlame" },
    init = function()
      vim.g.ghpr_github_auth_token = {
        ["github.com"] = vim.env.HOMEBREW_GITHUB_API_TOKEN,
        [vim.env.GITHUB_ENTERPRISE_HOST] = vim.env.GITHUB_ENTERPRISE_API_TOKEN_GHPRBLAME,
      }
      vim.g.ghpr_github_api_url = {
        [vim.env.GITHUB_ENTERPRISE_HOST] = vim.env.GITHUB_ENTERPRISE_API_PATH,
      }
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
      palette "visual_eof" {
        nord = function(colors)
          api.set_hl(0, "VisualEOL", { fg = colors.green })
          api.set_hl(0, "VisualNoEOL", { fg = colors.red })
        end,
      }
    end,
    opts = {
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
    opts = {
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
        opts = {
          render = "minimal",
          --[[
          background_colour = function()
            return palette.colors.black
          end,
          ]]
          level = "trace",
          on_open = function(win)
            api.win_set_config(win, { focusable = false })
          end,
        },
      },
    },
    init = function()
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

      palette "noice" {
        nord = function(colors)
          api.set_hl(0, "NoiceLspProgressSpinner", { fg = colors.white })
          api.set_hl(0, "NoiceLspProgressTitle", { fg = colors.orange })
          api.set_hl(0, "NoiceLspProgressClient", { fg = colors.yellow })
        end,
      }
    end,
    opts = {
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
    },
  },

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

  {
    "haringsrob/nvim_context_vt",
    event = { "BufNewFile", "BufRead", "FocusLost", "CursorHold" },
    wants = { "nvim-treesitter" },
    init = function()
      palette "context_vt" {
        nord = function(colors)
          api.set_hl(0, "ContextVt", { fg = colors.context })
        end,
      }
    end,
    opts = {
      prefix = "",
      highlight = "ContextVt",
    },
  },

  {
    "itchyny/vim-cursorword",
    event = { "FocusLost", "CursorHold" },
    init = function()
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("cursorword-colors", {}),
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
        lazy_require("gitsigns").setloclist(),
      },
      {
        "gQ",
        lazy_require("gitsigns").setqflist "all",
      },
    },
    init = function()
      palette "gitsigns" {
        nord = function(colors)
          api.set_hl(0, "GitSignsAdd", { fg = colors.green })
          api.set_hl(0, "GitSignsChange", { fg = colors.yellow })
          api.set_hl(0, "GitSignsDelete", { fg = colors.red })
          api.set_hl(0, "GitSignsCurrentLineBlame", { fg = colors.brighter_black })
          api.set_hl(0, "GitSignsAddInline", { bg = colors.bg_green })
          api.set_hl(0, "GitSignsChangeInline", { bg = colors.bg_yellow })
          api.set_hl(0, "GitSignsDeleteInline", { bg = colors.bg_red })
          api.set_hl(0, "GitSignsUntracked", { fg = colors.magenta })
        end,
      }
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
          local km = vim.keymap
          km.set("n", "]c", gs "next_hunk", { buffer = bufnr })
          km.set("n", "[c", gs "prev_hunk", { buffer = bufnr })
        end,
      }

      -- setup nvim-scrollbar
      require("scrollbar.handlers.gitsigns").setup()
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
      palette "virt_column" {
        nord = function(colors)
          api.set_hl(0, "ColorColumn", { bg = "NONE" })
          api.set_hl(0, "VirtColumn", { fg = colors.brighter_black })
        end,
      }
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
    opts = {
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

  { "rhysd/vim-textobj-ruby", dependencies = { "kana/vim-textobj-user" }, ft = { "ruby" } },

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
    config = function()
      local bufname = vim.fs.basename(api.buf_get_name(0))
      if bufname == "COMMIT_EDITMSG" or bufname == "MERGE_MSG" then
        fn["committia#open"] "git"
      end
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
      { [['j]], mode = { "n", "v" } },
      { [['k]], mode = { "n", "v" } },
    },
    init = function()
      palette "hop" {
        nord = function(colors)
          api.set_hl(0, "HopNextKey", { fg = colors.orange, bold = true })
          api.set_hl(0, "HopNextKey1", { fg = colors.cyan, bold = true })
          api.set_hl(0, "HopNextKey2", { fg = colors.dark_white })
          api.set_hl(0, "HopUnmatched", { fg = colors.gray })
        end,
      }
    end,
    config = function()
      local hop = require "hop"
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
    end,
  },

  {
    "ruifm/gitlinker.nvim",
    keys = { { "gc", mode = { "n", "v" } } },
    dependencies = { "plenary.nvim" },
    opts = function(_)
      return {
        opts = {
          add_current_line_on_normal_mode = false,
          action_callback = function(url)
            local actions = require "gitlinker.actions"
            actions.copy_to_clipboard(url)
            actions.open_in_browser(url)
          end,
        },
        callbacks = {
          [vim.g.gh_e_host or ""] = function(url_data)
            return require("gitlinker.hosts").get_github_type_url(url_data)
          end,
        },
        mappings = "gc",
      }
    end,
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
    dependencies = { { "lambdalisue/kensaku.vim" } },
    init = function()
      local km = vim.keymap
      local searchx = function(name)
        return function(opt)
          return function()
            require("lazy").load { plugins = { "vim-searchx" } }
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
      fn["denops#plugin#register"]("kensaku", { mode = "skip" })
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
          elseif input:match "^%." then
            return input:sub(2)
          end
          -- If the input contains spaces, it tries fuzzy matching.
          local converted = vim.tbl_map(fn["kensaku#query"], fn.split(input, " "))
          return fn.join(converted, [[.\{-}]])
        end,
      }

      api.set_hl(0, "SearchxMarker", { link = "DiffChange" })
      api.set_hl(0, "SearchxMarkerCurrent", { link = "WarningMsg" })
    end,
  },

  { "delphinus/characterize.nvim", config = true },
  { "delphinus/f_meta.nvim" },
  { "delphinus/lazy_require.nvim" },
  {
    --"nvim-lua/plenary.nvim",
    "delphinus/plenary.nvim",
    branch = "feature/scan_dir_async_cancel",
  },

  {
    "mrjones2014/op.nvim",
    build = "make install",
    cmd = {
      "OpAnalyzeBuffer",
      "OpCreate",
      "OpEdit",
      "OpInsert",
      "OpNote",
      "OpOpen",
      "OpSidebar",
      "OpSignin",
      "OpSignout",
      "OpView",
      "OpWhoami",
    },
    dependencies = { { "stevearc/dressing.nvim" } },
    opts = {
      signin_on_start = true,
    },
  },

  {
    "yuki-yano/fuzzy-motion.vim",
    keys = { { "s", "<Cmd>FuzzyMotion<CR>", mode = { "n", "x" } } },
    dependencies = { { "lambdalisue/kensaku.vim" } },
    init = function()
      vim.g.fuzzy_motion_labels = vim.split("HJKLASDFGYUIOPQWERTNMZXCVB", "")
      vim.g.fuzzy_motion_matchers = "kensaku"
    end,
    config = function()
      palette "fuzzy_motion" {
        nord = function(colors)
          api.set_hl(0, "FuzzyMotionShade", { fg = colors.gray })
          api.set_hl(0, "FuzzyMotionChar", { fg = colors.red })
          api.set_hl(0, "FuzzyMotionSubChar", { fg = colors.yellow })
          api.set_hl(0, "FuzzyMotionMatch", { fg = colors.cyan })
        end,
      }
      fn["denops#plugin#register"]("kensaku", { mode = "skip" })
      fn["denops#plugin#register"] "fuzzy-motion"
    end,
  },

  {
    "uga-rosa/ccc.nvim",
    event = { "BufEnter" },
    config = function()
      palette "ccc" {
        function(colors)
          local ccc = require "ccc"
          ccc.setup {
            highlighter = { auto_enable = true },
            pickers = {
              ccc.picker.hex,
              ccc.picker.custom_entries(colors),
            },
          }
        end,
      }
    end,
  },
}
