return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  config = function()
    require("copilot").setup({
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<Tab>",
          accept_word = "<C-L>",
          accept_line = "<C-CR>",
          next = "<C-]>",
          prev = "<C-[>",
          dismiss = "<ESC>",
        },
      },
      filetypes = {
        markdown = true,
        yaml = true,
        help = true,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
      },
    })
  end,
}
