return {
  "yetone/avante.nvim",
  lazy = false,
  version = false,
  opts = {
    provider = "copilot",
  },
  build = "make",
  dependencies = {
    "stevearc/dressing.nvim",
    "MunifTanjim/nui.nvim",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      event = "BufEnter",
      opts = {
        file_types = { "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
