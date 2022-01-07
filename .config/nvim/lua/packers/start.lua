return {
  -- TODO: needed here?
  { "nvim-lua/plenary.nvim" },

  -- basic {{{
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {
        ignore_lsp = { "bashls", "efm", "tsserver" },
        patterns = { ".git" },
        show_hidden = true,
      }
    end,
  },

  -- TODO: https://github.com/antoinemadec/FixCursorHold.nvim
  {
    "antoinemadec/FixCursorHold.nvim",
    config = [[vim.g.cursorhold_updatetime = 100]],
  },

  "delphinus/agrp.nvim",
  "delphinus/artify.nvim",
  "delphinus/f_meta.nvim",

  {
    "delphinus/characterize.nvim",
    config = function()
      require("characterize").setup {}
    end,
  },

  { "delphinus/vim-auto-cursorline" },
  { "delphinus/vim-quickfix-height" },

  {
    "direnv/direnv.vim",
    config = function()
      vim.g.direnv_silent_load = 1
    end,
  },

  { "editorconfig/editorconfig-vim" },

  -- TODO: remove this when Neovim includes this
  { "lewis6991/impatient.nvim" },

  {
    "nvim-lualine/lualine.nvim",
    requires = {
      { "kyazdani42/nvim-web-devicons", opt = true },
    },
    config = function()
      vim.loop.new_timer():start(
        0, -- never timeout
        500, -- repeat every 500 ms
        vim.schedule_wrap(function()
          vim.cmd [[redrawtabline]]
        end)
      )

      local function lsp()
        local clients = vim.lsp.buf_get_clients()
        local result = ""
        for _, lsp in pairs(clients) do
          if result ~= "" then
            result = result .. " "
          end
          result = result .. ("%s(%d)"):format(lsp.name, lsp.id)
        end
        return result
      end

      local characterize = require "characterize"
      local function char_info()
        local char = characterize.cursor_char()
        local results = characterize.info_table(char)
        if #results == 0 then
          return "NUL"
        end
        local r = results[1]
        local text = ("<%s> %s"):format(r.char, r.codepoint)
        if r.digraphs and #r.digraphs > 0 then
          text = text .. ", \\<C-K>" .. r.digraphs[1]
        end
        if r.description ~= "<unknown>" then
          text = text .. ", " .. r.description
        end
        if r.shikakugoma then
          text = text .. ", " .. r.shikakugoma
        end
        return text
      end

      local function monospace(value)
        -- TODO: Disable monospace glyphs temporarily
        return value
        --return vim.g.goneovim == 1 and value or
        --require'artify'(value, 'monospace')
      end

      local function treesitter_tag()
        local tag = require("nvim-treesitter").statusline {
          separator = " » ",
          transform_fn = function(t)
            return t:gsub("%s*[%[%(%{].*$", "")
          end,
        }
        return tag and tag ~= "" and tag or nil
      end

      local function tagbar_tag()
        local t = fn["tagbar#currenttag"]("%s", "", "f", "scoped-stl")
        local type = fn["tagbar#currenttagtype"]("%s", "")
        return t ~= "" and type ~= "" and ("%s (%s)"):format(t, type) or nil
      end

      local function tag()
        local ok1, ts = pcall(treesitter_tag)
        if ok1 and ts then
          return ts
        end
        local ok2, tb = pcall(tagbar_tag)
        return ok2 and tb and tb or "«no tag»"
      end

      require("lualine").setup {
        extensions = { "quickfix" },
        options = {
          theme = "nord",
          section_separators = "",
          component_separators = "❘",
        },
        sections = {
          lualine_a = {
            { "mode", fmt = monospace },
          },
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = {},
          lualine_y = { "filetype" },
          lualine_z = { "location" },
        },
        tabline = {
          lualine_a = {},
          lualine_b = {
            { "branch", fmt = monospace },
            { lsp, color = { fg = "#ebcb8b" } },
            {
              "diff",
              symbols = {
                added = "↑",
                modified = "→",
                removed = "↓",
              },
            },
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
              diagnostics_color = {
                error = { fg = "#e5989f" },
                warn = { fg = "#ebcb8b" },
                info = { fg = "#8ca9cd" },
                hint = { fg = "#616e88" },
              },
              symbols = {
                error = "●", -- U+25CF
                warn = "○", -- U+25CB
                info = "■", -- U+25A0
                hint = "□", -- U+25A1
              },
            },
          },
          lualine_c = {
            { "filename", fmt = monospace },
            { tag, separator = "❘" },
          },
          lualine_x = {
            { char_info, separator = "❘" },
            "encoding",
            { "fileformat", padding = { right = 2 } },
          },
          lualine_y = {},
          lualine_z = {},
        },
      }
    end,
  },

  { "lambdalisue/suda.vim" },

  {
    "rcarriga/nvim-notify",
    config = function()
      vim.opt.termguicolors = true
      local notify = require "notify"
      notify.setup {
        render = "minimal",
        background_colour = "#3b4252",
        on_open = function(win)
          api.win_set_config(win, { focusable = false })
        end,
      }
      vim.notify = notify
    end,
  },

  {
    "tpope/vim-eunuch",
    config = function()
      vim.env.SUDO_ASKPASS = loop.os_homedir() .. "/git/dotfiles/bin/macos-askpass"
    end,
  },

  {
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "git", [[<Cmd>Git<CR>]])
      vim.keymap.set("n", "g<Space>", [[<Cmd>Git<CR>]])
      vim.keymap.set("n", "d<", [[<Cmd>diffget //2<CR>]])
      vim.keymap.set("n", "d>", [[<Cmd>diffget //3<CR>]])
      vim.keymap.set("n", "gs", [[<Cmd>Gstatus<CR>]])
    end,
  },

  { "tpope/vim-repeat" },
  { "tpope/vim-rhubarb" },

  {
    -- 'tpope/vim-unimpaired',
    "delphinus/vim-unimpaired",
    config = function()
      vim.keymap.set("n", "[w", [[<Cmd>colder<CR>]])
      vim.keymap.set("n", "]w", [[<Cmd>cnewer<CR>]])
      vim.keymap.set("n", "[O", [[<Cmd>lopen<CR>]])
      vim.keymap.set("n", "]O", [[<Cmd>lclose<CR>]])
    end,
  },

  { "vim-jp/vimdoc-ja" },
  --{'wincent/terminus'},
  { "delphinus/terminus" },
  -- }}}

  -- vim-script {{{
  { "vim-scripts/HiColors" },
  -- }}}

  -- lua-script {{{
  {
    "LumaKernel/nvim-visual-eof.lua",
    config = function()
      require("visual-eof").setup {
        text_EOL = " ",
        text_NOEOL = " ",
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
      }
    end,
  },

  { "folke/todo-comments.nvim" },
  -- }}}
}

-- vim:se fdm=marker:
