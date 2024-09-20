return {
  {
    "catppuccin/nvim",
    event = "VimEnter",
    name = "catppuccin",
    opts = {},
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "mvllow/modes.nvim",
    config = function()
      require("modes").setup({
        line_opacity = 0.15,
        set_cursorline = false,
        ignore_filetypes = { "NvimTree", "TelescopePrompt", "dashboard", "minifiles" },
      })
    end,
  },
}
