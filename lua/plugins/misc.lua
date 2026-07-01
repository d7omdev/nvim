return {
  {
    "aserowy/tmux.nvim",
    lazy = true,
    keys = {
      { "<C-h>", "<cmd>lua require('tmux').move_left()<cr>", desc = "Move to left tmux pane" },
      { "<C-j>", "<cmd>lua require('tmux').move_bottom()<cr>", desc = "Move to bottom tmux pane" },
      { "<C-k>", "<cmd>lua require('tmux').move_top()<cr>", desc = "Move to top tmux pane" },
      { "<C-l>", "<cmd>lua require('tmux').move_right()<cr>", desc = "Move to right tmux pane" },
    },
    config = function()
      return require("tmux").setup({ copy_sync = {
        enable = false,
      } })
    end,
  },
  {
    "lambdalisue/vim-suda",
    cmd = { "SudaRead", "SudaWrite" },
    config = function()
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
    event = "BufReadPost", -- Delay slightly for better startup
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
    event = "BufReadPost",
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
    "nvim-mini/mini.diff",
    event = "VeryLazy",
    version = "*",
  },
  {
    "barrett-ruth/live-server.nvim",
    build = "bun add -g live-server",
    cmd = { "LiveServerStart", "LiveServerStop" },
    config = true,
  },
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerRunCmd", "OverseerToggle", "OverseerOpen" },
    config = function()
      require("overseer").setup()
    end,
  },
  {
    "mohseenrm/marko.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      {
        "dm",
        function()
          local line = vim.api.nvim_win_get_cursor(0)[1]
          local deleted = {}
          for i = 65, 90 do
            local mark = string.char(i)
            local pos = vim.api.nvim_get_mark(mark, {})
            if pos[1] == line then
              vim.api.nvim_del_mark(mark)
              table.insert(deleted, mark)
            end
          end
          if #deleted > 0 then
            vim.notify(
              "Deleted mark(s): " .. table.concat(deleted, ", "),
              vim.log.levels.INFO,
              { title = "marko.nvim" }
            )
          else
            vim.notify("No mark on current line", vim.log.levels.WARN, { title = "marko.nvim" })
          end
        end,
        desc = "Marko: delete mark under cursor",
      },
      { "<leader>mi", "<cmd>MarkoInfo<cr>", desc = "Marko: info" },
      { "<leader>ml", "<cmd>MarkoList<cr>", desc = "Marko: list" },
      { "<leader>mc", "<cmd>MarkoClean<cr>", desc = "Marko: clean" },
      { "<leader>ms", "<cmd>MarkoSave<cr>", desc = "Marko: save" },
    },
    config = function()
      require("marko").setup()
    end,
  },
  {
    "esmuellert/vscode-diff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
  },
  -- {
  --   "chrisgrieser/nvim-lsp-endhints",
  --   event = "LspAttach",
  --   config = function()
  --     require("lsp-endhints").setup()
  --   end,
  -- },
  {
    "chriswritescode-dev/consolelog.nvim",
    config = function()
      require("consolelog").setup()
    end,
  },
  {
    "Wansmer/symbol-usage.nvim",
    enabled = false,
    event = "BufReadPre",
    config = function()
      require("symbol-usage").setup()
    end,
  },
  {
    "Owen-Dechow/videre.nvim",
    cmd = "Videre",
    dependencies = {
      "Owen-Dechow/graph_view_yaml_parser", -- Optional: add YAML support
      "Owen-Dechow/graph_view_toml_parser", -- Optional: add TOML support
      "a-usr/xml2lua.nvim", -- Optional | Experimental: add XML support
    },
    opts = {
      box_style = "sharp",
    },
  },
}
