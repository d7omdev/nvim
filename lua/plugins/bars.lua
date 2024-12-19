return {
  "OXY2DEV/bars-N-lines.nvim",
  enabled = false,
  config = function()
    local bars = require("bars")
    bars.setup({
      exclude_filetypes = { "dashboard", "markdown", "markdown.mdx", "", "codecompanion" },
      statuscolumn = true,
      statusline = false,
      tabline = false,
    })
  end,
  lazy = false, -- Ensure it's not lazy-loaded if that's not what you want
}
