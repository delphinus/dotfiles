return {
  nord = {
    ---@type fun()[]
    run = {
      function()
        require("nord").update {
          italic = true,
          uniform_status_lines = true,
          uniform_diff_background = true,
          cursor_line_number_background = true,
          language_specific_highlights = false,
        }
      end,
    },
    config = function()
      local api = require("core.utils").api
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("nord_overrides", {}),
        pattern = "nord",
        callback = function()
          api.set_hl(0, "Comment", { fg = "#72809a", italic = true })
          api.set_hl(0, "Delimiter", { fg = "#81a1c1" })
          api.set_hl(0, "Constant", { fg = "#d8dee9", italic = true })
          -- TODO
          -- hi Folded guifg=#72809a gui=NONE
          api.set_hl(0, "Folded", { fg = "#72809a" })
          api.set_hl(0, "Identifier", { fg = "#8fbcbb" })
          api.set_hl(0, "Special", { fg = "#d08770" })
          api.set_hl(0, "Title", { fg = "#88c0d0", bold = true })
          api.set_hl(0, "PmenuSel", { blend = 0 })
          -- TODO
          -- hi VertSplit gui=NONE
          api.set_hl(0, "NormalFloat", { fg = "#d8dee9", bg = "#3b4252", blend = 10 })
          api.set_hl(0, "FloatBorder", { fg = "#8fbcbb", bg = "#3b4252", blend = 10 })
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
      local keymap = vim.keymap
      keymap.set("n", "<A-C>", [[<Cmd>ColorizerToggle<CR>]], { silent = true })
      keymap.set("n", "<A-S-Ç>", [[<Cmd>ColorizerToggle<CR>]], { silent = true })
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
      local keymap = vim.keymap
      vim.g.git_messenger_no_default_mappings = true
      keymap.set("n", "<A-b>", [[<Cmd>GitMessenger<CR>]])
      keymap.set("n", "<A-∫>", [[<Cmd>GitMessenger<CR>]])
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
          api.create_autocmd(
            { "BufUnload", "FileWritePre", "BufWritePre" },
            { group = api.create_augroup("Autodate", {}), command = "Autodate" }
          )
        end,
      })
    end,
  },

  dwm = {
    cond = function()
      local fn = vim.fn
      -- Do not load when it is loading committia.vim
      local file = fn.expand "%"
      local not_to_load = { "COMMIT_EDITMSG", "MERGE_MSG" }
      for _, name in ipairs(not_to_load) do
        if file:match(name) then
          return false
        end
      end
      return true
    end,
    config = function()
      local api, keymap = require("core.utils").api, vim.keymap
      local dwm = require "dwm"
      dwm.setup {
        key_maps = false,
        master_pane_count = 1,
        master_pane_width = "60%",
      }
      keymap.set("n", "<C-j>", "<C-w>w")
      keymap.set("n", "<C-k>", "<C-w>W")
      keymap.set("n", "<A-CR>", dwm.focus)
      keymap.set("n", "<C-@>", dwm.focus)
      keymap.set("n", "<C-Space>", dwm.focus)
      keymap.set("n", "<C-l>", dwm.grow)
      keymap.set("n", "<C-h>", dwm.shrink)
      keymap.set("n", "<C-n>", dwm.new)
      keymap.set("n", "<C-q>", dwm.rotateLeft)
      keymap.set("n", "<C-s>", dwm.rotate)
      keymap.set("n", "<C-c>", function()
        -- TODO: copied logic from require'scrollbar'.clear
        local state = vim.b.scrollbar_state
        if state and state.winnr then
          local ok = pcall(api.win_close, state.winnr, true)
          if not ok then
            api.echo({
              { "cannot found scrollbar win: " .. state.winnr, "WarningMsg" },
            }, true, {})
          end
          vim.b.scrollbar_state = { size = state.size, bufnr = state.bufnr }
        end
        dwm:close()
      end)

      api.create_autocmd("BufRead", {
        group = api.create_augroup("dwm_preview", {}),
        callback = function()
          -- TODO: vim.opt has no 'previewwindow'?
          if vim.wo.previewwindow then
            vim.b.dwm_disabled = 1
          end
        end,
      })
    end,
  },

  context_vt = function()
    local api = require("core.utils").api
    api.set_hl(0, "ContextVt", { fg = "#365f86" })
    require("nvim_context_vt").setup { highlight = "ContextVt" }
  end,

  gitsign = function()
    local api = require("core.utils").api
    api.set_hl(0, "GitSignsAdd", { fg = "#a3be8c" })
    api.set_hl(0, "GitSignsChange", { fg = "#ebcb8b" })
    api.set_hl(0, "GitSignsDelete", { fg = "#bf616a" })
    api.set_hl(0, "GitSignsCurrentLineBlame", { fg = "#616e88" })
    api.set_hl(0, "GitSignsAddInline", { bg = "#183203" })
    api.set_hl(0, "GitSignsChangeInline", { bg = "#432d00" })
    api.set_hl(0, "GitSignsDeleteInline", { bg = "#52050c" })
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
      },
      numhl = true,
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 10,
      },
      word_diff = true,
      on_attach = function(bufnr)
        local keymap = vim.keymap
        keymap.set("n", "]c", gs "next_hunk", { buffer = bufnr })
        keymap.set("n", "[c", gs "prev_hunk", { buffer = bufnr })
      end,
    }
  end,

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
    api.set_hl(0, "ColorColumn", { bg = "NONE" })
    api.set_hl(0, "VirtColumn", { fg = "#616e88" })
    local vt = require "virt-column"
    vt.setup { char = "⡂" }
    api.create_autocmd("TermEnter", {
      callback = function()
        vt.clear_buf(0)
      end,
    })
  end,

  coffee_script = {
    setup = function()
      local api = require("core.utils").api
      api.create_autocmd({ "BufNewFile", "BufRead" }, {
        group = api.create_augroup("detect_cson", {}),
        pattern = "*.cson",
        command = [[setf coffee]],
      })
    end,
  },

  ansible = function()
    vim.g.ansible_name_highlight = "b"
    vim.g.ansible_extra_keywords_highlight = 1
  end,

  committia = {
    setup = function()
      local fn, keymap = vim.fn, vim.keymap
      vim.g.committia_hooks = {
        edit_open = function(info)
          if info.vcs == "git" and fn.getline(1) == "" then
            vim.cmd.startinsert()
          end
          keymap.set("i", "<A-d>", [[<Plug>(committia-scroll-diff-down-half)]], { buffer = true })
          keymap.set("i", "<A-∂>", [[<Plug>(committia-scroll-diff-down-half)]], { buffer = true })
          keymap.set("i", "<A-u>", [[<Plug>(committia-scroll-diff-up-half)]], { buffer = true })
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
      local keymap = vim.keymap
      vim.g.fold_cycle_default_mapping = 0
      keymap.set("n", "<A-l>", [[<Plug>(fold-cycle-open)]])
      keymap.set("n", "<A-¬>", [[<Plug>(fold-cycle-open)]])
      keymap.set("n", "<A-h>", [[<Plug>(fold-cycle-open)]])
      keymap.set("n", "<A-˙>", [[<Plug>(fold-cycle-open)]])
    end,
  },

  miniyank = {
    setup = function()
      local keymap = vim.keymap
      vim.g.miniyank_maxitems = 100
      keymap.set("n", "p", [[<Plug>(miniyank-autoput)]])
      keymap.set("n", "P", [[<Plug>(miniyank-autoPut)]])
      keymap.set("n", "<A-p>", [[<Plug>(miniyank-cycle)]])
      keymap.set("n", "<A-π>", [[<Plug>(miniyank-cycle)]])
      keymap.set("n", "<A-P>", [[<Plug>(miniyank-cycleback)]])
      keymap.set("n", "<A-S-∏>", [[<Plug>(miniyank-cycleback)]])
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
    local keymap = vim.keymap
    local hop = require "hop"
    hop.setup {
      keys = "hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB",
      extend_visual = true,
    }
    local direction = require("hop.hint").HintDirection
    keymap.set({ "n", "v" }, [['j]], function()
      if fn.getcmdwintype() == "" then
        hop.hint_lines { direction = direction.AFTER_CURSOR }
      end
    end)
    keymap.set({ "n", "v" }, [['k]], function()
      if fn.getcmdwintype() == "" then
        hop.hint_lines { direction = direction.BEFORE_CURSOR }
      end
    end)
    if vim.opt.background:get() == "dark" then
      api.set_hl(0, "HopNextKey", { fg = "#d08770", bold = true })
      api.set_hl(0, "HopNextKey1", { fg = "#88c0d0", bold = true })
      api.set_hl(0, "HopNextKey2", { fg = "#d8dee9" })
      api.set_hl(0, "HopUnmatched", { fg = "#4c566a" })
    end
  end,

  gitlinker = function()
    local actions = require "gitlinker.actions"
    require("gitlinker").setup {
      opts = {
        add_current_line_on_normal_mode = false,
        action_callback = function(url)
          actions.copy_to_clipboard(url)
          actions.open_in_browser(url)
        end,
      },
      callbacks = {
        [vim.g.gh_e_host] = require("gitlinker.hosts").get_github_type_url,
      },
      mappings = "gc",
    }
  end,

  quickhl = {
    setup = function()
      local keymap = vim.keymap
      keymap.set({ "n", "x" }, "<Space>m", [[<Plug>(quickhl-manual-this)]])
      keymap.set({ "n", "x" }, "<Space>t", [[<Plug>(quickhl-manual-toggle)]])
      keymap.set({ "n", "x" }, "<Space>M", [[<Plug>(quickhl-manual-reset)]])
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
      local keymap = vim.keymap
      keymap.set({ "n", "x", "o" }, "[j", [[<Plug>(columnskip:nonblank:next)]])
      keymap.set({ "n", "x", "o" }, "[k", [[<Plug>(columnskip:nonblank:prev)]])
      keymap.set({ "n", "x", "o" }, "]j", [[<Plug>(columnskip:first-nonblank:next)]])
      keymap.set({ "n", "x", "o" }, "]k", [[<Plug>(columnskip:first-nonblank:prev)]])
    end,
  },

  searchx = {
    setup = function()
      local fn, keymap = vim.fn, vim.keymap
      local searchx = function(name)
        return function(opt)
          return function()
            local f = fn["searchx#" .. name]
            return opt and f(opt) or f()
          end
        end
      end

      -- Overwrite / and ?.
      keymap.set({ "n", "x" }, "?", searchx "start" { dir = 0 })
      keymap.set({ "n", "x" }, "/", searchx "start" { dir = 1 })
      keymap.set("c", "<A-;>", searchx "select"())

      -- Move to next/prev match.
      keymap.set({ "n", "x" }, "N", searchx "prev"())
      keymap.set({ "n", "x" }, "n", searchx "next"())
      keymap.set({ "c", "n", "x" }, "<A-z>", searchx "prev"())
      keymap.set({ "c", "n", "x" }, "<A-x>", searchx "next"())

      -- Clear highlights
      keymap.set("n", "<Esc><Esc>", searchx "clear"())
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
          local dict = vim.env.HOMEBREW_PREFIX .. "/opt/cmigemo/share/migemo/utf-8/migemo-dict"
          local re
          require("plenary.job")
            :new({
              command = "cmigemo",
              args = { "-v", "-d", dict, "-w", input:sub(2) },
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

  fterm = {
    setup = function()
      local keymap = vim.keymap
      local loaded
      local function toggle_fterm()
        if not loaded then
          require("FTerm").setup {
            cmd = vim.opt.shell:get(),
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
          }
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
          loaded = true
        end
        require("FTerm").toggle()
      end

      keymap.set({ "n", "t" }, "<A-c>", toggle_fterm)
      keymap.set({ "n", "t" }, "<A-ç>", toggle_fterm)
    end,
    config = function()
      local api = require("core.utils").api
      api.set_hl(0, "WinBorderTop", { fg = "#ebf5f5", blend = 30 })
      api.set_hl(0, "WinBorderLeft", { fg = "#c2dddc", blend = 30 })
      api.set_hl(0, "WinBorderRight", { fg = "#8fbcbb", blend = 30 })
      api.set_hl(0, "WinBorderBottom", { fg = "#5d9794", blend = 30 })
      api.set_hl(0, "WinBorderLight", { fg = "#c2dddc", bg = "#5d9794", blend = 30 })
      api.set_hl(0, "WinBorderDark", { fg = "#5d9794", bg = "#c2dddc", blend = 30 })
      api.set_hl(0, "WinBorderTransparent", { bg = "#111a2c" })
    end,
  },

  scrollbar = {
    setup = function()
      --
    end,

    config = function()
      require("scrollbar").setup {}
    end,
  },

  noice = {
    setup = function()
      local api = require("core.utils").api

      local orig = vim.notify
      vim.notify = function(...)
        vim.notify = orig
        require "notify"
        require "noice"
        vim.notify(...)
      end

      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("noice-colors", {}),
        once = true,
        callback = function()
          api.set_hl(0, "NoiceLspProgressSpinner", { fg = "#e5e9f0" })
          api.set_hl(0, "NoiceLspProgressTitle", { fg = "#d08770" })
          api.set_hl(0, "NoiceLspProgressClient", { fg = "#ebcb8b" })
        end,
      })
    end,

    config = function()
      require("noice").setup {
        cmdline = {
          icons = {
            ["/"] = { icon = "", hl_group = "DiagnosticWarn" },
            ["?"] = { icon = "", hl_group = "DiagnosticWarn" },
            [":"] = { icon = "", hl_group = "DiagnosticInfo" },
          },
        },
        popupmenu = {
          backend = "cmp",
        },
        lsp_progress = {
          enabled = true,
        },
        hacks = {
          skip_duplicate_messages = true,
        },
        format = {
          spinner = {
            name = "dots12",
            --name = "sand",
          },
        },
      }
    end,
  },

  notify = function()
    vim.opt.termguicolors = true
    require("notify").setup {
      render = "minimal",
      background_colour = "#3b4252",
      level = "trace",
      on_open = function(win)
        api.win_set_config(win, { focusable = false })
      end,
    }
  end,
}
