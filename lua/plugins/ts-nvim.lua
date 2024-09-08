-- this file will hold ts stuff
return {
  {
    "davidosomething/format-ts-errors.nvim",
    event = "VeryLazy",
    {
      "OlegGulevskyy/better-ts-errors.nvim",
      event = "VeryLazy",
      dependencies = { "MunifTanjim/nui.nvim" },
      config = {
        keymaps = {
          toggle = "<leader>dd", -- default '<leader>dd'
          go_to_definition = "<leader>dx", -- default '<leader>dx'
        },
      },
    },
  },
}
