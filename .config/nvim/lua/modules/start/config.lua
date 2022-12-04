return {
  unimpaired = function()
    local km = vim.keymap
    km.set("n", "[w", [[<Cmd>colder<CR>]])
    km.set("n", "]w", [[<Cmd>cnewer<CR>]])
    km.set("n", "[O", [[<Cmd>lopen<CR>]])
    km.set("n", "]O", [[<Cmd>lclose<CR>]])
  end,

  visual_eof = function()
    local api = require("core.utils").api
    local palette = require "core.utils.palette" "nord"
    api.create_autocmd("ColorScheme", {
      group = api.create_augroup("nord_visual_eof", {}),
      pattern = "nord",
      callback = function()
        api.set_hl(0, "VisualEOL", { fg = palette.green })
        api.set_hl(0, "VisualNoEOL", { fg = palette.red })
      end,
    })
    require("visual-eof").setup {
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
    }
  end,

  cellwidths = {
    config = function()
      --[[
      local function measure(name, f)
        local s = os.clock()
        f()
        vim.notify(("%s took %f ms"):format(name, (os.clock() - s) * 1000))
      end
      ]]

      vim.opt.listchars = {
        tab = "▓░",
        trail = "↔",
        eol = "⏎",
        extends = "→",
        precedes = "←",
        nbsp = "␣",
      }
      vim.opt.fillchars = {
        diff = "░",
        eob = "‣",
        fold = "░",
        foldopen = "▾",
        foldsep = "│",
        foldclose = "▸",
      }
      require("cellwidths").setup {
        name = "user/custom",
        --log_level = "DEBUG",
        ---@param cw cellwidths
        fallback = function(cw)
          cw.load "sfmono_square"
          cw.add { 0xf0000, 0x10ffff, 2 }
          return cw
        end,
      }
    end,
    run = function()
      vim.cmd.CellWidthsRemove()
    end,
  },

  eunuch = function()
    local _, uv, _ = require("core.utils").globals()
    vim.env.SUDO_ASKPASS = uv.os_homedir() .. "/git/dotfiles/bin/macos-askpass"
  end,
}
