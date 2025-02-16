return {
  "folke/noice.nvim",
  enabled = true,
  event = "VeryLazy",
  opts = {
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
            { find = "fewer lines" },
          },
        },
        view = "mini",
      },
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "Agent service not initialized" },
          },
        },
        opts = { skip = true },
      },
    },
    views = {
      -- Clean cmdline_popup + palette
      cmdline_popup = {
        position = {
          row = 10,
          col = "50%",
        },
        border = {
          style = "single",
        },
        size = {
          min_width = 60,
          width = "auto",
          height = "auto",
        },
      },
      cmdline_popupmenu = {
        relative = "editor",
        position = {
          row = 13,
          col = "50%",
        },
        size = {
          width = 60,
          height = "auto",
          max_height = 15,
        },
        border = {
          style = "none",
          padding = { 0, 3 },
        },
      },
      hover = {
        border = {
          style = "single",
        },
      },
      confirm = {
        border = {
          style = "single",
        },
      },
      popup = {
        border = {
          style = "single",
        },
      },
    },
  },
}
