return {
  lualine = function()
    local lualine = require("modules.start.config.lualine").new()
    return lualine:config()
  end,

  notify = function()
    local fn, uv, api = require("core.utils").globals()
    vim.opt.termguicolors = true
    local notify = require "notify"
    notify.setup {
      render = "minimal",
      background_colour = "#3b4252",
      level = "debug",
      on_open = function(win)
        api.win_set_config(win, { focusable = false })
      end,
    }
    vim.notify = notify
  end,

  fugitive = function()
    vim.keymap.set("n", "git", [[<Cmd>Git<CR>]])
    vim.keymap.set("n", "g<Space>", [[<Cmd>Git<CR>]])
    vim.keymap.set("n", "d<", [[<Cmd>diffget //2<CR>]])
    vim.keymap.set("n", "d>", [[<Cmd>diffget //3<CR>]])
    vim.keymap.set("n", "gs", [[<Cmd>Gstatus<CR>]])
  end,

  unimpaired = function()
    vim.keymap.set("n", "[w", [[<Cmd>colder<CR>]])
    vim.keymap.set("n", "]w", [[<Cmd>cnewer<CR>]])
    vim.keymap.set("n", "[O", [[<Cmd>lopen<CR>]])
    vim.keymap.set("n", "]O", [[<Cmd>lclose<CR>]])
  end,

  visual_eof = function()
    local fn, uv, api = require("core.utils").globals()
    api.create_autocmd("ColorScheme", {
      group = api.create_augroup("nord_visual_eof", {}),
      pattern = "nord",
      callback = function()
        api.set_hl(0, "VisualEOL", { fg = "#a3be8c" })
        api.set_hl(0, "VisualNoEOL", { fg = "#bf616a" })
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
}
