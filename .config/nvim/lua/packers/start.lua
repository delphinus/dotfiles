return {
  -- TODO: needed here?
  { "nvim-lua/plenary.nvim" },

  -- basic {{{
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {
        ignore_lsp = { "bashls", "null-ls", "tsserver" },
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

  "delphinus/artify.nvim",
  "delphinus/f_meta.nvim",

  {
    "delphinus/characterize.nvim",
    config = function()
      require("characterize").setup {}
    end,
  },

  { "delphinus/vim-quickfix-height" },

  {
    "direnv/direnv.vim",
    config = function()
      vim.g.direnv_silent_load = 1
    end,
  },

  { "editorconfig/editorconfig-vim" },

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

      local function tag()
        local ok, ts = pcall(treesitter_tag)
        return ok and ts or "«no tag»"
      end

      -- https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets
      local truncate = require("plenary.strings").truncate
      local function truncator(str, settings, no_ellipsis)
        local columns = vim.opt.columns:get()
        if type(settings[1]) ~= "table" then
          settings = { settings }
        end
        for _, t in ipairs(settings) do
          local width = t[1]
          local len = t[2]
          if columns < width and #str > len then
            if len == 0 then
              return ""
            end
            return truncate(str, len, (no_ellipsis and "" or nil))
          end
        end
        return str
      end

      local function tr(settings)
        return function(str)
          return truncator(str, settings)
        end
      end

      local function no_ellipsis_tr(settings)
        return function(str)
          return truncator(str, settings, true)
        end
      end

      require("lualine").setup {
        extensions = { "quickfix" },
        options = {
          theme = "nord",
          section_separators = "",
          component_separators = "❘",
          globalstatus = true,
        },
        sections = {
          lualine_a = { { "mode", fmt = no_ellipsis_tr { 80, 4 } } },
          lualine_b = { { "filename", fmt = tr { { 40, 0 }, { 80, 10 }, { 100, 30 } } } },
          lualine_c = {
            { "branch", fmt = tr { { 80, 0 }, { 90, 10 } } },
            { lsp, color = { fg = "#ebcb8b" }, fmt = tr { 100, 0 } },
            {
              "diff",
              symbols = {
                added = "↑",
                modified = "→",
                removed = "↓",
              },
              fmt = tr { 110, 0 },
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
              fmt = tr { 120, 0 },
            },
          },
          lualine_x = { { "filetype", fmt = tr { 100, 0 } } },
          lualine_y = {
            { "progress", fmt = tr { 90, 0 } },
            { "filesize", fmt = tr { 120, 0 } },
          },
          lualine_z = { { "location", fmt = tr { 50, 0 } } },
        },
        tabline = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { tag, separator = "❘" } },
          lualine_x = { { char_info, fmt = tr { 80, 0 } } },
          lualine_y = {
            { "encoding", fmt = tr { 90, 0 } },
            { "fileformat", padding = { right = 2 }, fmt = tr { 90, 0 } },
          },
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
      api.create_autocmd("ColorScheme", {
        group = api.create_augroup("nord_visual_eof", {}),
        pattern = "nord",
        callback = function()
          vim.cmd [[
            hi VisualEOL   guifg=#a3be8c
            hi VisualNoEOL guifg=#bf616a
          ]]
        end,
      })
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

  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      local nls = require "null-ls"
      local helpers = require "null-ls.helpers"
      local methods = require "null-ls.methods"
      local utils = require "null-ls.utils"

      local function use_prettier()
        return utils.make_conditional_utils().root_has_file {
          ".eslintrc",
          ".eslintrc.json",
          ".eslintrc.yaml",
          ".eslintrc.yml",
          ".prettierrc",
          ".prettierrc.json",
          ".prettierrc.yaml",
          ".prettierrc.yml",
        }
      end

      nls.setup {
        sources = {
          nls.builtins.diagnostics.luacheck,
          nls.builtins.diagnostics.mypy,
          nls.builtins.diagnostics.shellcheck,
          nls.builtins.diagnostics.vint,
          nls.builtins.diagnostics.yamllint,
          nls.builtins.formatting.gofmt,
          nls.builtins.formatting.gofumpt,
          nls.builtins.formatting.goimports,
          nls.builtins.formatting.golines,
          nls.builtins.formatting.stylua,

          nls.builtins.formatting.deno_fmt.with {
            generator_opts = {
              runtime_condition = function(_)
                local r = not use_prettier()
                vim.notify("deno_fmt: " .. (r and "true" or "false"))
                return not use_prettier()
              end,
            },
          },

          nls.builtins.formatting.prettier.with {
            generator_opts = {
              runtime_condition = function(_)
                local r = use_prettier()
                vim.notify("prettier: " .. (r and "true" or "false"))
                return use_prettier()
              end,
            },
          },

          nls.builtins.formatting.shfmt.with {
            generator_opts = {
              command = "shfmt",
              args = { "-i", "2", "-sr", "-filename", "$FILENAME" },
              to_stdin = true,
            },
          },

          nls.builtins.diagnostics.textlint.with { filetypes = { "markdown" } },

          helpers.make_builtin {
            name = "perlcritic",
            meta = {
              url = "https://example.com",
              description = "TODO",
            },
            method = methods.internal.DIAGNOSTICS,
            filetypes = { "perl" },
            generator_opts = {
              command = "perlcritic",
              to_stdin = true,
              from_stderr = true,
              args = { "--severity", "1", "--verbose", "%s:%l:%c:%m (%P)\n" },
              format = "line",
              check_exit_code = function(code)
                return code >= 1
              end,
              on_output = function(params, done)
                print "p1"
                local output = params.output
                if not output then
                  print "p2"
                  return done()
                end

                print "p3"
                local from_severity_numbers = { ["5"] = "w", ["4"] = "i", ["3"] = "n", ["2"] = "n", ["1"] = "n" }
                local lines = vim.tbl_map(function(line)
                  return line:gsub("Perl::Critic::Policy::", "", 1):gsub("^%d", function(severity_number)
                    return from_severity_numbers[severity_number]
                  end, 1)
                end, utils.split_at_newline(params.bufnr, output))

                local diagnostics = {}
                local qflist = vim.fn.getqflist { efm = "%t:%l:%c:%m", lines = lines }
                local severities = { w = 2, i = 3, n = 4 }

                for _, item in pairs(qflist.items) do
                  if item.valid == 1 then
                    local col = item.col > 0 and item.col - 1 or 0
                    table.insert(diagnostics, {
                      row = item.lnum,
                      col = col,
                      source = "perlcritic",
                      message = item.text,
                      severity = severities[item.type],
                    })
                  end
                end

                return done(diagnostics)
              end,
            },
            factory = helpers.generator_factory,
          },
        },

        on_attach = function(client, bufnr)
          if client.supports_method "textDocument/formatting" then
            api.create_autocmd("BufWritePre", {
              group = api.create_augroup("null_ls_formatting", {}),
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format {
                  filter = function(clients)
                    return vim.tbl_filter(function(c)
                      return c.name ~= "tsserver"
                    end, clients)
                  end,
                }
              end,
            })
          end
        end,
      }
    end,
  },
  -- }}}
}

-- vim:se fdm=marker:
