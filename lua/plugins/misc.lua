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
  {
    "jackMort/tide.nvim",
    config = function()
      require("tide").setup({
        keys = {
          leader = "=", -- Leader key to prefix all Tide commands
          panel = "=", -- Open the panel (uses leader key as prefix)
          add_item = "a", -- Add a new item to the list (leader + 'a')
          delete = "d", -- Remove an item from the list (leader + 'd')
          clear_all = "x", -- Clear all items (leader + 'x')
          horizontal = "-", -- Split window horizontally (leader + '-')
          vertical = "|", -- Split window vertically (leader + '|')
        },
        animation_duration = 300, -- Animation duration in milliseconds
        animation_fps = 30, -- Frames per second for animations
        hints = {
          dictionary = "qwertzuiopsfghjklycvbnm", -- Key hints for quick access
        },
      })
    end,
    requires = {
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
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
  -- Disabling these plugins if nvchad ui is used
  { "nvim-lualine/lualine.nvim", enabled = false },
  { "akinsho/bufferline.nvim", enabled = false },

  -- Also apply these configs
  {
    "bbjornstad/pretty-fold.nvim",
    config = function()
      require("pretty-fold").setup({
        keep_indentation = false,
        fill_char = "━",
        sections = {
          left = {
            "━ ",
            function()
              return string.rep("*", vim.v.foldlevel)
            end,
            " ━┫",
            "content",
            "┣",
          },
          right = {
            "┫ ",
            "number_of_folded_lines",
            ": ",
            "percentage",
            " ┣━━",
          },
        },
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = true,
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
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
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup({
        line_num = {
          enable = true,
        },
        chunk = {
          enable = true,
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = "•",
          },
        },
      })
    end,
  },
  {
    "2kabhishek/nerdy.nvim",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Nerdy",
  },

  -- Godot
  { "habamax/vim-godot" },
}
