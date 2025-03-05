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
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    enabled = function()
      return not (vim.fn.filereadable("src/App.vue") == 1 or vim.fn.filereadable("nuxt.config.ts") == 1)
    end,
    ft = {
      "typescript",
      "typescriptreact",
      "javascript",
      "javascriptreact",
    },

    config = function(_, opts)
      local api = require("typescript-tools.api")

      opts.handlers = {
        ["textDocument/publishDiagnostics"] = api.filter_diagnostics({
          80001, -- Ignore this might be converted to a ES export
        }),
      }

      require("typescript-tools").setup(opts)
    end,
    opts = {
      expose_as_code_action = "all",
      complete_function_calls = true,
      jsx_close_tag = {
        enable = true,
        filetypes = { "javascriptreact", "typescriptreact" },
      },
      on_attach = function(config, bufNr)
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
    },
  },
}
