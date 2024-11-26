return {

  "HiPhish/rainbow-delimiters.nvim",
  enabled = false,
  config = function()
    -- This module contains a number of default definitions
    local rainbow_delimiters = require("rainbow-delimiters")

    local highlight_groups = {
      RainbowDelimiterRed = "#BB5D64", -- Yellow
      RainbowDelimiterYellow = "#BB9D66", -- Yellow
      RainbowDelimiterBlue = "#4F8EC2", -- Blue
      RainbowDelimiterOrange = "#AC7F56", -- Orange
      RainbowDelimiterGreen = "#789A60", -- Green
      RainbowDelimiterViolet = "#936EB8", -- Violet
      RainbowDelimiterCyan = "#46949E", -- Cyan
    }

    for group, color in pairs(highlight_groups) do
      vim.api.nvim_set_hl(0, group, { fg = color })
    end

    ---@type rainbow_delimiters.config
    vim.g.rainbow_delimiters = {
      strategy = {
        [""] = rainbow_delimiters.strategy["global"],
        vim = rainbow_delimiters.strategy["local"],
      },
      query = {
        [""] = "rainbow-delimiters",
        lua = "rainbow-blocks",
      },
      priority = {
        [""] = 110,
        lua = 210,
      },
      highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
    }
  end,
}
