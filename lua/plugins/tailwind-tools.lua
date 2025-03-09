return {
  {
    "luckasRanarison/tailwind-tools.nvim",
    event = "BufRead",
    enabled = function()
      return not vim.tbl_contains({ "AvanteInput", "minifiles", "snacks_dashboard", "blade" }, vim.bo.filetype)
        and vim.bo.buftype ~= "prompt"
        and vim.b.completion ~= false
    end,
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "typescriptreact", "astro", "vue" },
    opts = {
      server = {
        override = true, -- setup the server from the plugin if true
        settings = {}, -- shortcut for `settings.tailwindCSS`
      },
      document_color = {
        enabled = true, -- can be toggled by commands
        kind = "background", -- "inline" | "foreground" | "background"
        inline_symbol = "󰝤 ", -- only used in inline mode
        debounce = 100, -- in milliseconds, only applied in insert mode
      },
      conceal = {
        enabled = true, -- can be toggled by commands
        min_length = 20, -- only conceal classes exceeding the provided length
        symbol = "󱏿", -- only a single character is allowed
        highlight = { -- extmark highlight options, see :h 'highlight'
          fg = "#38BDF8",
        },
      },
      cmp = {
        highlight = "foreground", -- color preview style, "foreground" | "background"
      },
    },
  },
}
