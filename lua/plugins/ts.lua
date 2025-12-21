local map = vim.keymap.set

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

  {
    "pmizio/typescript-tools.nvim",
    enabled = function()
      return not (vim.fn.filereadable("src/App.vue") == 1 or vim.fn.filereadable("nuxt.config.ts") == 1)
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
      "davidosomething/format-ts-errors.nvim",
    },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    config = function()
      local api = require("typescript-tools.api")

      require("typescript-tools").setup({

        handlers = {
          ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
            if not result.diagnostics then
              return
            end
            local formatter_map = require("format-ts-errors")
            local idx = 1
            while idx <= #result.diagnostics do
              local entry = result.diagnostics[idx]
              local formatter = formatter_map[entry.code]
              entry.message = formatter and formatter(entry.message) or entry.message
              if entry.code == 80001 then
                table.remove(result.diagnostics, idx)
              else
                idx = idx + 1
              end
            end
            vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
          end,
        },

        settings = {
          expose_as_code_action = "all",
          complete_function_calls = true,
          jsx_close_tag = {
            enable = true,
            filetypes = { "javascriptreact", "typescriptreact" },
          },
        },
      })
      map("n", "gd", "<cmd>TSToolsGoToSourceDefinition<CR>", { desc = "Go to source definition", buffer = bufNr })
      map("n", "gR", "<cmd>TSToolsFileReferences<CR>", { desc = "File References", buffer = bufNr })
      map({ "n", "v" }, "<leader>co", "<cmd>TSToolsOrganizeImports<CR>", { desc = "Organize Imports", buffer = bufNr })
      map({ "n", "v" }, "<leader>cS", "<cmd>TSToolsSortImports<CR>", { desc = "Sort Imports", buffer = bufNr })
      map(
        { "n", "v" },
        "<leader>cr",
        "<cmd>TSToolsRemoveUnusedImports<CR>",
        { desc = "Remove Unused Imports", buffer = bufNr }
      )
      map(
        { "n", "v" },
        "<leader>cM",
        "<cmd>TSToolsAddMissingImports<CR>",
        { desc = "Add Missing Imports", buffer = bufNr }
      )
      map({ "n", "v" }, "<leader>rF", "<cmd>TSToolsRenameFile<CR>", { desc = "Rename File", buffer = bufNr })
      map({ "n", "v" }, "<leader>cD", "<cmd>TSToolsFixAll<CR>", { desc = "Fix All Diagnostics", buffer = bufNr })
    end,
  },
}
