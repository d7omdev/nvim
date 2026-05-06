return {
  "salkhalil/summon.nvim",
  event = "BufRead",
  opts = {},
  config = function()
    require("summon").setup({
      -- Global defaults (apply to all commands unless overridden)
      width = 0.85,
      height = 0.85,
      border = "single",
      close_keymap = "<Esc><Esc>",
      highlights = {
        float = { bg = "NONE" },
        border = { fg = "#d79921", bg = "NONE" },
        title = { fg = "#282828", bg = "#d79921", bold = true },
      },
      -- Colors accept hex strings ("#282828") or integers (0x282828)
      terminal_passthrough_keys = { "<C-o>", "<C-i>" }, -- keys passed to terminal apps

      -- Named commands
      commands = {
        claude = {
          type = "terminal", -- or "file"
          command = "claude",
          title = " Claude ",
          keymap = "<leader>C",
        },
        -- lazygit = {
        --   type = "terminal",
        --   command = "lazygit",
        --   title = " LazyGit ",
        --   keymap = "<leader>gg",
        --   height = 0.9, -- override global default
        --   border_color = "#89b4fa", -- custom border + title badge color
        --   terminal_passthrough_keys = {}, -- disable passthrough for lazygit
        -- },
        todos = {
          type = "file",
          command = "~/Documents/todos.md",
          title = " TODOs ",
          keymap = "<leader>t",
          filetype = "markdown", -- optional: override auto-detected filetype
        },
      },
    })
  end,
}
