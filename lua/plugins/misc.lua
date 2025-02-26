return {
  {
    "aserowy/tmux.nvim",
    event = "VeryLazy",
    config = function()
      return require("tmux").setup({ copy_sync = {
        enable = false,
      } })
    end,
  },
  {
    "lambdalisue/vim-suda",
    event = "VeryLazy",
    config = function()
      vim.g.suda_smart_edit = 1
      -- Expand 'ss' into 'SudaWrite' in the command line
      vim.cmd([[cab ss SudaWrite<CR>]])
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
    priority = 1000,
    lazy = false,
    build = function()
      require("base46").load_all_highlights()
    end,
  },

  {
    "bbjornstad/pretty-fold.nvim",
    event = "BufRead",
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
    event = "BufRead",
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
    version = "*",
  },

  {
    "2kabhishek/nerdy.nvim",
    event = "VeryLazy",
    dependencies = {
      "stevearc/dressing.nvim",
    },
    cmd = "Nerdy",
  },
  {
    "smoka7/multicursors.nvim",
    enabled = false,
    event = "BufRead",
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
    event = "BufRead",
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
  {
    "aaronik/treewalker.nvim",
    event = "BufRead",
    opts = {
      highlight = true,
      highlight_duration = 250,
      highlight_group = "CursorLine",
    },
  },
  { "habamax/vim-godot", event = "FileType gd" },
  { { "RishabhRD/nvim-cheat.sh", event = "VeryLazy" }, { "RishabhRD/popfix", event = "VeryLazy" } },
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    config = function()
      require("quicker").setup()
    end,
  },
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        use_absolute_path = false, ---@type boolean
        relative_to_current_file = true, ---@type boolean
        dir_path = function()
          return vim.fn.expand("%:t:r") .. "-img"
        end,
        prompt_for_file_name = true, ---@type boolean
        file_name = "%Y-%m-%d-at-%H-%M-%S", ---@type string
        process_cmd = "convert - png:-", ---@type string
      },
      filetypes = {
        markdown = {
          url_encode_path = true, ---@type boolean
          template = "![$FILE_NAME]($FILE_PATH)", ---@type string
        },
      },
    },
    keys = {
      { "<leader>v", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },
  {
    "echasnovski/mini.diff",
    version = "*",
    config = function()
      require("mini.diff").setup({
        -- Options for how hunks are visualized
        view = {
          -- Visualization style. Possible values are 'sign' and 'number'.
          -- Default: 'number' if line numbers are enabled, 'sign' otherwise.
          style = vim.go.number and "number" or "sign",
          -- Signs used for hunks with 'sign' view
          signs = { add = "▒", change = "▒", delete = "▒" },
          -- Priority of used visualization extmarks
          priority = 199,
        },
      })
    end,
  },
}
