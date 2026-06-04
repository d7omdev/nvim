return {
  "carlos-algms/agentic.nvim",
  dependencies = {
    { "hakonharnes/img-clip.nvim", opts = {} },
  },
  opts = {
    provider = "pi-acp",
    diff_preview = {
      enabled = true,
      layout = "inline",
      center_on_navigate_hunks = true,
    },
    acp_providers = {
      ["pi-acp"] = {
        name = "Pi ACP",
        command = "pi-acp",
      },
    },
  },

  keys = {
    {
      "<C-\\>",
      function()
        require("agentic").toggle()
      end,
      mode = { "n", "v", "i" },
      desc = "Toggle Agentic Chat",
    },
    {
      "<M-\\>",
      function()
        require("agentic").add_selection_or_file_to_context()
      end,
      mode = { "n", "v" },
      desc = "Add file or selection to Agentic context",
    },
    {
      "<C-,>",
      function()
        require("agentic").new_session()
      end,
      mode = { "n", "v", "i" },
      desc = "New Agentic Session",
    },
    {
      "<A-i>r",
      function()
        require("agentic").restore_session()
      end,
      desc = "Agentic Restore session",
      silent = true,
      mode = { "n", "v", "i" },
    },
    {
      "<leader>ad",
      function()
        require("agentic").add_current_line_diagnostics()
      end,
      desc = "Add current line diagnostic to Agentic",
      mode = { "n" },
    },
    {
      "<leader>aD",
      function()
        require("agentic").add_buffer_diagnostics()
      end,
      desc = "Add all buffer diagnostics to Agentic",
      mode = { "n" },
    },
  },
}
