return {
  "OXY2DEV/bars-N-lines.nvim",
  config = function()
    local bars = require("bars")
    bars.setup({
      statuscolumn = true,
      statusline = false,
      tabline = false,
    })
  end,
  lazy = false, -- Ensure it's not lazy-loaded if that's not what you want
}
