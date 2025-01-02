local lspconfig = require("lspconfig")
lspconfig.gdscript.setup({
  cmd = { "nc", "localhost", "6005" }, -- Connect to Godot's language server
  filetypes = { "gd", "gdscript", "gdscript3" }, -- GDScript file types
  root_dir = lspconfig.util.root_pattern("project.godot"), -- Root is the Godot project
  on_attach = function(client, bufnr)
    -- Keybindings for LSP functionality
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts) -- Go to definition
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts) -- Show hover info
  end,
})

return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    --- @class lspconfig
    opts = {
      diagnostics = {
        virtual_text = false,
      },
      inlay_hints = {
        enabled = true,
        exclude = {
          "typescriptreact",
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescript.tsx",
          "vue",
        },
      },
      codelens = {
        enabled = false,
      },
      servers = {
        vtsls = {
          enabled = false,
        },
      },
    },
  },
  {
    "nvimdev/lspsaga.nvim",
    config = function()
      require("lspsaga").setup({
        lightbulb = {
          enable = false,
          sign = false,
        },
        code_action = { extend_gitsigns = false, num_shortcut = true },
        diagnostic = {
          max_height = 0.8,
          max_width = 0.5,
          max_show_width = 0.5,
          keys = {
            quit = { "q", "<ESC>" },
          },
        },
      })
    end,
  },
}
