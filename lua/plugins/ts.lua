local map = vim.keymap.set
-- this file will hold ts stuff
return {
  {
    "davidosomething/format-ts-errors.nvim",
    event = "VeryLazy",
    config = function()
      require("format-ts-errors").setup({
        add_markdown = true,
        start_indent_level = 0,
      })
    end,
  },
  -- LSP
  {
    "pmizio/typescript-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    ft = {
      "typescript",
      "typescriptreact",
      "javascript",
      "javascriptreact",
      "vue",
    },
    config = function()
      local api = require("typescript-tools.api")

      require("typescript-tools").setup({
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
        },
        on_attach = function(client, bufNr)
          map("n", "gD", "<cmd>TSToolsGoToSourceDefinition<CR>", {
            desc = "Go to source definition",
            silent = true,
            buffer = bufNr,
          })
          -- TSToolsFileReferences
          map("n", "gR", "<cmd>TSToolsFileReferences<CR>", {
            desc = "File References",
            silent = true,
            buffer = bufNr,
          })
          map(
            { "n", "v" },
            "<leader>co",
            "<cmd>TSToolsOrganizeImports<CR>",
            { desc = "Imports Organize", silent = true, buffer = bufNr }
          )
          map(
            { "n", "v" },
            "<leader>cS",
            "<cmd>TSToolsSortImports<CR>",
            { desc = "Imports Sort", silent = true, buffer = bufNr }
          )
          map({ "n", "v" }, "<leader>cr", "<cmd>TSToolsRemoveUnusedImports<CR>", {
            desc = "Imports remove unused",
            silent = true,
            buffer = bufNr,
          })
          map({ "n", "v" }, "<leader>cM", "<cmd>TSToolsAddMissingImports<CR>", {
            desc = "Add missing imports",
            silent = true,
            buffer = bufNr,
          })
          map(
            { "n", "v" },
            "<leader>rF",
            "<cmd>TSToolsRenameFile<CR>",
            { desc = "Rename File", silent = true, buffer = bufNr }
          )
          -- TSToolsFixAll
          map({ "n", "v" }, "<leader>cD", "<cmd>TSToolsFixAll<CR>", {
            desc = "Fix all diagnostics",
            silent = true,
            buffer = bufNr,
          })
        end,
        handlers = {
          ["textDocument/publishDiagnostics"] = api.filter_diagnostics({
            80001, -- Ignore this might be converted to a ES export
          }),
        },
        settings = {
          -- For Vue support
          tsserver_plugins = {
            "@vue/typescript-plugin",
          },
          -- Enable all code actions
          expose_as_code_action = "all",
          complete_function_calls = true,
          jsx_close_tag = {
            enable = true,
            filetypes = { "javascriptreact", "typescriptreact" },
          },
        },
      })
    end,
  },
}
