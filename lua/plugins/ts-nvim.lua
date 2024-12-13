-- this file will hold ts stuff
return {
  {
    "davidosomething/format-ts-errors.nvim",
    event = "VeryLazy",
  },

  {
    "piersolenski/telescope-import.nvim",
    event = "VeryLazy",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function()
      require("telescope").load_extension("import")
    end,
  },
}
