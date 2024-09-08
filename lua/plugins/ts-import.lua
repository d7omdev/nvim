return {
  "piersolenski/telescope-import.nvim",
  event = "VeryLazy",
  dependencies = "nvim-telescope/telescope.nvim",
  config = function()
    require("telescope").load_extension("import")
  end,
}
