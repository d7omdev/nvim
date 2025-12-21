return {
  {
    "yetone/avante.nvim",
    enabled = false,
    build = "make",
    event = "BufReadPre",
    opts = {
      provider = "claude",
      claude = {},
      hints = { enabled = false },
      file_selector = {
        provider = "snacks",
      },
    },
    config = function(_, opts)
      require("avante").setup(opts)
    end,
  },
  {
    "stevearc/dressing.nvim",
    lazy = true,
    opts = {
      input = { enabled = false },
      select = { enabled = false },
    },
  },
  {
    "saghen/blink.compat",
    lazy = true,
    config = function()
      local cmp = require("cmp")
      cmp.ConfirmBehavior = {
        Insert = "insert",
        Replace = "replace",
      }
    end,
  },
  {
    "saghen/blink.cmp",
    lazy = true,
    opts = {
      sources = {
        compat = { "avante_commands", "avante_mentions", "avante_files" },
      },
    },
  },
}
