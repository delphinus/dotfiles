-- nvim-cmp (CMP=1) 使用時だけの skkeleton 連携。Karabiner-Elements 連携は
-- 補完エンジンと無関係なので core.skkeleton_karabiner に分けてある。
local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("skkeleton_cmp", {})

  vim.api.nvim_create_autocmd("User", {
    desc = "Set up skkeleton settings with nvim-cmp",
    group = group,
    pattern = "skkeleton-enable-pre",
    callback = function()
      local compare = require "cmp.config.compare"
      local types = require "cmp.types"
      require("cmp").setup.buffer {
        formatting = { fields = { types.cmp.ItemField.Abbr } },
        sources = { { name = "skkeleton", keyword_pattern = [=[\V\[ーぁ-ゔァ-ヴｦ-ﾟ]]=] } },
        sorting = {
          priority_weight = 2,
          comparators = {
            compare.recently_used,
            compare.order,
          },
        },
      }
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    desc = "Restore the default settings for nvim-cmp",
    group = group,
    pattern = "skkeleton-disable-pre",
    callback = function()
      require("cmp").setup.buffer {}
    end,
  })
end

return M
