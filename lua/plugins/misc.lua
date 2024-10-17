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

  -- Menu
  { "nvchad/volt", lazy = true },
  { "nvchad/minty", lazy = true },
  {
    "nvchad/menu",

    lazy = true,
    config = function()
      require("menu").open({
        {
          name = "Format Buffer",
          cmd = function()
            local ok, conform = pcall(require, "conform")

            if ok then
              conform.format({ lsp_fallback = true })
            else
              vim.lsp.buf.format()
            end
          end,
          rtxt = "<leader>cf",
        },
      })
    end,
  },
  vim.keymap.set("n", "<RightMouse>", function()
    vim.cmd.exec('"normal! \\<RightMouse>"')

    local options = vim.bo.ft == "NvimTree" and "nvimtree" or "default"
    require("menu").open(options, { mouse = true })
  end, {}),
}
