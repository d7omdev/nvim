return {
  {
    "OXY2DEV/markview.nvim",
    enabled = true,
    event = "BufRead",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      preview = {
        filetypes = { "markdown" },
        ignore_buftypes = {},
      },
    },
  },
}
