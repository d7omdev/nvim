return {
  "d7omdev/nuget.nvim",
  event = "VeryLazy",
  config = function()
    require("nuget").setup()
  end,
}
