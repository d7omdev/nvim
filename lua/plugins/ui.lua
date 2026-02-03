return {
  {
    "catppuccin/nvim",
    event = "BufRead",
  },
  { "tiagovla/scope.nvim", config = true },
  {
    "akinsho/bufferline.nvim",
    enabled = true,
    config = require("plugins.config.bufferline"),
  },
  {
    "mvllow/modes.nvim",
    event = "BufRead",
    enabled = true,
    config = require("plugins.config.modes"),
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    enabled = true,
    priority = 1000, -- needs to be loaded in first
    opts = {
      preset = "simple",
      options = {
        show_source = true,
        use_icons_from_diagnostic = true,
        show_all_diags_on_cursorline = true,
      },
    },
  },

  {
    "rachartier/tiny-glimmer.nvim",
    branch = "main",
    event = "TextYankPost",
    opts = {
      default_animation = "fade",
      overwrite = {
        search = {
          enabled = false,
          default_animation = "pulse",
          next_mapping = "nzzzv",
          prev_mapping = "Nzzzv",
        },
        paste = {
          enabled = true,
          default_animation = "reverse_fade",
          paste_mapping = "p",
          Paste_mapping = "P",
        },
        undo = {
          enabled = true,
          default_animation = {
            name = "fade",
          },
          undo_mapping = "u",
        },
        redo = {
          enabled = true,
          default_animation = {
            name = "reverse_fade",
          },
          redo_mapping = "<c-r>",
        },
      },
    },
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    enabled = false,
    config = function()
      vim.diagnostic.config({ virtual_lines = { only_current_line = true } })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lazy", "text" },
        callback = function()
          vim.diagnostic.config({ virtual_lines = false })
        end,
      })
      require("lsp_lines").setup()
    end,
  },
  {
    "folke/drop.nvim",
    opts = {
      filetypes = { "dashboard", "alpha", "ministarter", "snacks_dashboard" },
    },
  },
}
