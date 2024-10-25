return {
  {
    "catppuccin/nvim",
    event = "VimEnter",
    name = "catppuccin",
    opts = {
      transparent_background = true,
    },
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
  {
    "mistricky/codesnap.nvim",
    build = "make build_generator",
    keys = {
      { "<leader>cs", "", mode = "x", desc = "+Code Snap" },
      { "<leader>csc", "<cmd>CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
      { "<leader>css", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "Save selected code snapshot in ~/Pictures" },
    },
    opts = {
      save_path = "~/Pictures/CodeSnap/",
      has_breadcrumbs = true,
      bg_theme = "grape",
      code_font_family = "JetBrainsMono Nerd Font",
      watermark = "",
    },
  },
  {
    "mikesmithgh/borderline.nvim",
    enabled = true,
    lazy = true,
    event = "VeryLazy",
    config = function()
      require("borderline").setup({
        --  ...
      })
    end,
  },
}
