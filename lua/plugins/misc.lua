return {
  {
    "aserowy/tmux.nvim",
    config = function()
      return require("tmux").setup({ copy_sync = {
        enable = false,
      } })
    end,
  },
  {
    "lambdalisue/vim-suda",
    config = function()
      vim.g.suda_smart_edit = 1
      -- Expand 'ss' into 'SudaWrite' in the command line
      vim.cmd([[cab ss SudaWrite]])
    end,
  },
  { "nvchad/volt", lazy = true },
  { "nvchad/minty", lazy = true },
  {
    "nvchad/ui",
    config = function()
      require("nvchad")
    end,
  },
  {
    "nvchad/base46",
    lazy = true,
    build = function()
      require("base46").load_all_highlights()
    end,
  },

  {
    "bbjornstad/pretty-fold.nvim",
    config = function()
      require("pretty-fold").setup({
        keep_indentation = true,
        fill_char = "",
        sections = {
          left = {
            "+",
            function()
              return string.rep("-", vim.v.foldlevel)
            end,
            " ",
            "number_of_folded_lines",
            ":",
            "content",
          },
        },
      })
    end,
  },
  {
    "andrewferrier/debugprint.nvim",
    opts = {
      keymaps = {
        normal = {
          plain_below = "g?p",
          plain_above = "g?P",
          variable_below = "g?v",
          variable_above = "g?V",
          variable_below_alwaysprompt = nil,
          variable_above_alwaysprompt = nil,
          textobj_below = "g?o",
          textobj_above = "g?O",
          toggle_comment_debug_prints = nil,
          delete_debug_prints = nil,
        },
        insert = {
          plain = "<C-G>p",
          variable = "<C-G>v",
        },
        visual = {
          variable_below = "g?v",
          variable_above = "g?V",
        },
      },
      commands = {
        toggle_comment_debug_prints = "ToggleCommentDebugPrints",
        delete_debug_prints = "DeleteDebugPrints",
      },
    },
    dependencies = {
      "echasnovski/mini.nvim",
    },
    version = "*",
  },

  {
    "2kabhishek/nerdy.nvim",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Nerdy",
  },
  {
    "smoka7/multicursors.nvim",
    event = "VeryLazy",
    dependencies = {
      "smoka7/hydra.nvim",
    },
    opts = {},
    cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
    keys = {
      {
        mode = { "v", "n" },
        "<Leader>m",
        "<cmd>MCstart<cr>",
        desc = "Multi cursors",
      },
    },
  },
  {
    "Aasim-A/scrollEOF.nvim",
    event = "BufRead",
    config = function()
      require("scrollEOF").setup({
        disabled_filetypes = { "minifiles" },
      })
    end,
  },
  {
    "chrisgrieser/nvim-rip-substitute",
    cmd = "RipSubstitute",
    keys = {
      {
        "<leader>fs",
        function()
          require("rip-substitute").sub()
        end,
        mode = { "n", "x" },
        desc = " rip substitute",
      },
    },
  },
  -- Godot
  { "habamax/vim-godot" },
  require("fzf-lua").setup({ defaults = { git_icons = false } }),
}
