return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "InsertEnter",
  enabled = false,
  config = function()
    require("copilot").setup({
      filetypes = {
        ["opencode"] = false,
        ["grug-far"] = false,
      },
      should_attach = function(_, bufname)
        if string.match(bufname, "env") then
          return false
        end
        return true
      end,
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<Tab>",
          accept_word = "<C-L>",
          accept_line = "<C-CR>",
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
