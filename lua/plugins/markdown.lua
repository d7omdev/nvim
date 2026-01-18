return {
  {
    "OXY2DEV/markview.nvim",
    event = "BufRead",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      preview = {
        filetypes = { "codecompanion", "markdown" },
        ignore_buftypes = {},
      },
    },
  },
}
