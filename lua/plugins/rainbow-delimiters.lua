return {
  "HiPhish/rainbow-delimiters.nvim",
  enabled = true,
  config = function()
    -- This module contains a number of default definitions
    local rainbow_delimiters = require("rainbow-delimiters")
    local colors = dofile(vim.g.base46_cache .. "colors")

    local color_mappings = {
      RainbowRed = colors.red,
      RainbowYellow = colors.yellow,
      RainbowBlue = colors.blue,
      RainbowOrange = colors.orange,
      RainbowGreen = colors.green,
      RainbowViolet = colors.purple,
      RainbowCyan = colors.cyan,
      RainbowMagenta = colors.magenta,
      RainbowPink = colors.pink,
      RainbowBrown = colors.brown,
    }

    for name, color in pairs(color_mappings) do
      vim.api.nvim_set_hl(0, name, { fg = color })
    end

    ---@type rainbow_delimiters.config
    vim.g.rainbow_delimiters = {
      strategy = {
        [""] = rainbow_delimiters.strategy["global"],
        vim = rainbow_delimiters.strategy["local"],
      },
      query = {
        [""] = "rainbow-delimiters",
      },
      priority = {
        [""] = 110,
        lua = 210,
      },
      highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        -- "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
        "RainbowMagenta",
        "RainbowBrown",
      },
    }
  end,
}
