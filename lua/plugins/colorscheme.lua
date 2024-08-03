do
  return {
    {
      "catppuccin/nvim",
      lazy = false,
      name = "catppuccin",
      opts = {
        -- transparent_background = true,
        flavor = "mocha",
        -- background = {
        --   dark = "frappe",
        --   light = "frappe",
        -- },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          lsp_saga = true,
          neogit = true,
          markdown = true,
          noice = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
              ok = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
              ok = { "underline" },
            },
            inlay_hints = {
              background = true,
            },
          },
          harpoon = true,
          rainbow_delimiters = true,
          lsp_trouble = false,
          which_key = true,
          navic = { enabled = true, custom_bg = "lualine" },
          neotest = true,
          neotree = true,
          semantic_tokens = true,
          telescope = true,
          treesitter_context = true,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
        },
        default_integrations = true,
      },
    },
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "catppuccin",
      },
    },
    {
      -- "DaikyXendo/nvim-material-icon",
    },
    {
      -- Cursor color based on mode
      "mvllow/modes.nvim",
      tag = "v0.2.0",
      config = function()
        require("modes").setup()
      end,
    },
    { "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = ... },
  }
end
