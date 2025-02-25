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
    event = "BufRead",
    enabled = true,
    config = function()
      require("modes").setup({
        line_opacity = 0.15,
        set_cursorline = false,
        set_number = false,
        ignore_filetypes = { "NvimTree", "TelescopePrompt", "dashboard", "minifiles" },
      })
    end,
  },
  {
    "mistricky/codesnap.nvim",
    event = "BufRead",
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
    enabled = false,
    priority = 1000, -- needs to be loaded in first
    config = function()
      require("tiny-inline-diagnostic").setup({
        options = {
          show_source = true,
          use_icons_from_diagnostic = true,
          show_all_diags_on_cursorline = true,
        },
      })
    end,
  },
  -- {
  --   "Bekaboo/dropbar.nvim",
  --   event = "BufRead",
  --   config = function()
  --     local dropbar_api = require("dropbar.api")
  --     vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
  --     vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
  --     vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
  --   end,
  -- },
  {
    "rachartier/tiny-glimmer.nvim",
    branch = "main",
    event = "TextYankPost",
    opts = {
      default_animation = "left_to_right",
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
}
