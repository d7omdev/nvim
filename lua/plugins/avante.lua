return {
  {
    "yetone/avante.nvim",
    lazy = true,
    event = "BufRead",
    build = "make",

    opts = {
      provider = "copilot",
      hints = { enabled = false },
      file_selector = {
        provider = "snacks",
      },
    },

    dependencies = {
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "Avante" },
      },
    },
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
    opts = {},
    config = function()
      -- monkeypatch cmp.ConfirmBehavior for Avante
      require("cmp").ConfirmBehavior = {
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
