return {
  {
    "catppuccin/nvim",
    event = "BufRead",
    name = "catppuccin",
    opts = {
      -- transparent_background = true,
    },
  },
  {
    "mvllow/modes.nvim",
    enabled = true,
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
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000, -- needs to be loaded in first
    config = function()
      require("tiny-inline-diagnostic").setup({
        options = {
          show_source = true,
          use_icons_from_diagnostic = true,
        },
      })
    end,
  },
}
