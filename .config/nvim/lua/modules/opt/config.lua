local lazy_require = require "lazy_require"

return {
  nord = {
    ---@type fun()[]
    run = {
      lazy_require("nord").update {
        italic = true,
        uniform_status_lines = true,
        uniform_diff_background = true,
        cursor_line_number_background = true,
        language_specific_highlights = false,
      },
    },
    config = function()
      local api = require("core.utils").api
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

  table_mode = {
    setup = function()
      vim.g.table_mode_corner = "|"
      vim.keymap.set("n", "`tm", [[<Cmd>TableModeToggle<CR>]])
    end,
  },

  tig_explorer = function()
    local keymap = vim.keymap
    keymap.set("n", "<Leader>tT", [[<Cmd>TigOpenCurrentFile<CR>]])
    keymap.set("n", "<Leader>tt", [[<Cmd>TigOpenProjectRootDir<CR>]])
    keymap.set("n", "<Leader>tg", [[<Cmd>TigGrep<CR>]])
    keymap.set("n", "<Leader>tr", [[<Cmd>TigGrepResume<CR>]])
    keymap.set("v", "<Leader>tG", [[y<Cmd>TigGrep<Space><C-R>"<CR>]])
    keymap.set("n", "<Leader>tc", [[<Cmd><C-u>:TigGrep<Space><C-R><C-W><CR>]])
    keymap.set("n", "<Leader>tb", [[<Cmd>TigBlame<CR>]])
  end,

  markdown_preview = {
    setup = function()
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_open_to_the_world = 1
    end,
  },

  undotree = {
    setup = function()
      vim.g.undotree_HelpLine = 0
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_TreeNodeShape = "●"
      vim.g.undotree_WindowLayout = 2
      vim.keymap.set("n", "<A-u>", [[<Cmd>UndotreeToggle<CR>]])
    end,
  },

  colorizer = {
    setup = function()
      local km = vim.keymap
      km.set("n", "<A-C>", [[<Cmd>ColorizerToggle<CR>]], { silent = true })
      km.set("n", "<A-S-Ç>", [[<Cmd>ColorizerToggle<CR>]], { silent = true })
    end,
  },

  ghpr_blame = function()
    local fn, uv = require("core.utils").globals()
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

  git_messenger = {
    setup = function()
      vim.g.git_messenger_no_default_mappings = true
      vim.keymap.set("n", "<A-b>", [[<Cmd>GitMessenger<CR>]])
    end,
  },

  autodate = {
    setup = function()
      local api = require("core.utils").api
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

  dwm = {
    cond = function()
      -- HACK: Do not load when it is loading committia.vim
      local api = require("core.utils").api
      local file = vim.fs.basename(api.buf_get_name(0))
      local not_to_load = { "COMMIT_EDITMSG", "MERGE_MSG" }
      for _, name in ipairs(not_to_load) do
        if file == name then
          return false
        end
      end
      return true
    end,
    config = function()
      local api, km = require("core.utils").api, vim.keymap
      local dwm = require "dwm"
      dwm.setup {
        key_maps = false,
        master_pane_count = 1,
        master_pane_width = "60%",
      }
      km.set("n", "<C-j>", "<C-w>w")
      km.set("n", "<C-k>", "<C-w>W")
      km.set("n", "<A-CR>", dwm.focus)
      km.set("n", "<C-@>", dwm.focus)
      km.set("n", "<C-Space>", dwm.focus)
      km.set("n", "<C-l>", dwm.grow)
      km.set("n", "<C-h>", dwm.shrink)
      km.set("n", "<C-n>", dwm.new)
      km.set("n", "<C-q>", dwm.rotateLeft)
      km.set("n", "<C-s>", dwm.rotate)
      km.set("n", "<C-c>", dwm.close)

      api.create_autocmd("BufRead", {
        group = api.create_augroup("dwm_preview", {}),
        callback = function()
          vim.b.dwm_disabled = vim.opt.previewwindow:get() and 1 or nil
        end,
      })
    end,
  },

  context_vt = function()
    local api = require("core.utils").api
    local palette = require "core.utils.palette" "nord"
    api.set_hl(0, "ContextVt", { fg = palette.context })
    require("nvim_context_vt").setup {
      prefix = "󾪜",
      highlight = "ContextVt",
    }
  end,

  gitsign = {
    setup = function()
      local api = require("core.utils").api
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

  indent_blankline = {
    setup = function()
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

  virt_column = function()
    local api = require("core.utils").api
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

  ansible = function()
    vim.g.ansible_name_highlight = "b"
    vim.g.ansible_extra_keywords_highlight = 1
  end,

  committia = {
    setup = function()
      local fn, km = vim.fn, vim.keymap
      vim.g.committia_hooks = {
        edit_open = function(info)
          if info.vcs == "git" and fn.getline(1) == "" then
            vim.cmd.startinsert()
          end
          km.set("i", "<A-d>", [[<Plug>(committia-scroll-diff-down-half)]], { buffer = true })
          km.set("i", "<A-∂>", [[<Plug>(committia-scroll-diff-down-half)]], { buffer = true })
          km.set("i", "<A-u>", [[<Plug>(committia-scroll-diff-up-half)]], { buffer = true })
        end,
      }
    end,
  },

  perl = {
    setup = function()
      vim.g.perl_include_pod = 1
      vim.g.perl_string_as_statement = 1
      vim.g.perl_sync_dist = 1000
      vim.g.perl_fold = 1
      vim.g.perl_nofold_packages = 1
      vim.g.perl_fold_anonymous_subs = 1
      vim.g.perl_sub_signatures = 1
    end,
  },

  fold_cycle = {
    setup = function()
      local km = vim.keymap
      vim.g.fold_cycle_default_mapping = 0
      km.set("n", "<A-l>", [[<Plug>(fold-cycle-open)]])
      km.set("n", "<A-¬>", [[<Plug>(fold-cycle-open)]])
      km.set("n", "<A-h>", [[<Plug>(fold-cycle-open)]])
      km.set("n", "<A-˙>", [[<Plug>(fold-cycle-open)]])
    end,
  },

  miniyank = {
    setup = function()
      local km = vim.keymap
      vim.g.miniyank_maxitems = 100
      km.set("n", "p", [[<Plug>(miniyank-autoput)]])
      km.set("n", "P", [[<Plug>(miniyank-autoPut)]])
      km.set("n", "<A-p>", [[<Plug>(miniyank-cycle)]])
      km.set("n", "<A-π>", [[<Plug>(miniyank-cycle)]])
      km.set("n", "<A-P>", [[<Plug>(miniyank-cycleback)]])
      km.set("n", "<A-S-∏>", [[<Plug>(miniyank-cycleback)]])
    end,
  },

  easy_align = {
    setup = function()
      vim.keymap.set("v", "<CR>", "<Plug>(EasyAlign)")

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

  hop = function()
    local fn, _, api = require("core.utils").globals()
    local km = vim.keymap
    local hop = require "hop"
    local palette = require "core.utils.palette" "nord"
    hop.setup {
      keys = "hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB",
      extend_visual = true,
    }
    local direction = require("hop.hint").HintDirection
    km.set({ "n", "v" }, [['j]], function()
      if fn.getcmdwintype() == "" then
        hop.hint_lines { direction = direction.AFTER_CURSOR }
      end
    end)
    km.set({ "n", "v" }, [['k]], function()
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

  quickhl = {
    setup = function()
      local km = vim.keymap
      km.set({ "n", "x" }, "<Space>m", [[<Plug>(quickhl-manual-this)]])
      km.set({ "n", "x" }, "<Space>t", [[<Plug>(quickhl-manual-toggle)]])
      km.set({ "n", "x" }, "<Space>M", [[<Plug>(quickhl-manual-reset)]])
    end,
  },

  visualstar = {
    setup = function()
      vim.g.visualstar_no_default_key_mappings = 1
      vim.keymap.set("x", "*", [[<Plug>(visualstar-*)]])
    end,
  },

  columnskip = {
    setup = function()
      local km = vim.keymap
      km.set({ "n", "x", "o" }, "[j", [[<Plug>(columnskip:nonblank:next)]])
      km.set({ "n", "x", "o" }, "[k", [[<Plug>(columnskip:nonblank:prev)]])
      km.set({ "n", "x", "o" }, "]j", [[<Plug>(columnskip:first-nonblank:next)]])
      km.set({ "n", "x", "o" }, "]k", [[<Plug>(columnskip:first-nonblank:prev)]])
    end,
  },

  searchx = {
    setup = function()
      local fn, km = vim.fn, vim.keymap
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
      local fn, _, api = require("core.utils").globals()
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

  --[[
              {'╭', 'WinBorderTop'},
              {'─', 'WinBorderTop'},
              {' ', 'WinBorderTransparent'},
              {' ', 'WinBorderTransparent'},
              {' ', 'WinBorderTransparent'},
              {' ', 'WinBorderTransparent'},
              {' ', 'WinBorderTransparent'},
              {'│', 'WinBorderLeft'},
              ]]
  --[[
              {'█', 'WinBorderLight'},
              {'▀', 'WinBorderLight'},
              {'▀', 'WinBorderLight'},
              {'█', 'WinBorderDark'},
              {'▄', 'WinBorderLight'},
              {'▄', 'WinBorderLight'},
              {'█', 'WinBorderLight'},
              {'█', 'WinBorderLight'},
              ]]
  --[[
              {'▟', 'WinBorderLight'},
              {'▀', 'WinBorderLight'},
              {'▀', 'WinBorderLight'},
              {'▙', 'WinBorderDark'},
              {'█', 'WinBorderDark'},
              {'▛', 'WinBorderDark'},
              {'▄', 'WinBorderDark'},
              {'▜', 'WinBorderLight'},
              {'█', 'WinBorderLight'},
              ]]
  --[[
              {'╭', 'WinBorderTop'},
              {'─', 'WinBorderTop'},
              {'╮', 'WinBorderTop'},
              {'│', 'WinBorderRight'},
              {'╯', 'WinBorderBottom'},
              {'─', 'WinBorderBottom'},
              {'╰', 'WinBorderLeft'},
              {'│', 'WinBorderLeft'},
              {'⣠', 'WinBorderTop'},
              {'⣤', 'WinBorderTop'},
              {'⣄', 'WinBorderTop'},
              {'⣿', 'WinBorderRight'},
              {'⠋', 'WinBorderBottom'},
              {'⠛', 'WinBorderBottom'},
              {'⠙', 'WinBorderLeft'},
              {'⣿', 'WinBorderLeft'},
              ]]

  toggleterm = {
    setup = function()
      local api = require("core.utils").api
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("toggleterm-colors", {}),
        pattern = "nord",
        callback = function()
          local api = require("core.utils").api
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

      vim.keymap.set({ "n", "t" }, "<A-c>", "<Cmd>ToggleTerm<CR>")
    end,
  },

  noice = {
    setup = function()
      local api = require("core.utils").api
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

  fugitive = function()
    local km = vim.keymap
    km.set("n", "git", [[<Cmd>Git<CR>]])
    km.set("n", "g<Space>", [[<Cmd>Git<CR>]])
    km.set("n", "d<", [[<Cmd>diffget //2<CR>]])
    km.set("n", "d>", [[<Cmd>diffget //3<CR>]])
    km.set("n", "gs", [[<Cmd>Gstatus<CR>]])
  end,

  lualine = {
    setup = function()
      vim.opt.laststatus = 0
      vim.opt.showtabline = 0
    end,
    config = function()
      require("modules.start.config.lualine"):config()
    end,
  },

  cursorword = {
    setup = function()
      local api = require("core.utils").api
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("cursorword-colors", {}),
        pattern = "nord",
        callback = function()
          api.set_hl(0, "CursorWord", { undercurl = true })
        end,
      })
    end,
  },
}
