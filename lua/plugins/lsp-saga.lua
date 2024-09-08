return {
  "nvimdev/lspsaga.nvim",
  config = function()
    require("lspsaga").setup({
      lightbulb = {
        enable = false,
        sign = false,
      },
      code_action = { extend_gitsigns = false, num_shortcut = true },
      diagnostic = {
        max_height = 0.8,
        max_width = 0.5,
        max_show_width = 0.5,
        keys = {
          quit = { "q", "<ESC>" },
        },
      },
    })
  end,
}
