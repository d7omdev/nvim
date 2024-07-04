return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept_word = "<C-Right>",
          accept_line = "<Tab>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        yaml = true,
        help = true,
      },
    })
  end,
}
