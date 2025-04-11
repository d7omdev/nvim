local lspconfig = require("lspconfig")
local map = vim.keymap.set

--  Common `on_attach` Function for Keybindings
-- local function on_attach(client, bufNr)
--   -- General LSP Keybindings
--   map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration", silent = true, buffer = bufNr })
--   map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", silent = true, buffer = bufNr })
--   map("n", "gr", vim.lsp.buf.references, { desc = "Find references", silent = true, buffer = bufNr })
--   map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation", silent = true, buffer = bufNr })
--
--   -- Organize Imports
--   map("n", "<leader>co", function()
--     vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
--     vim.lsp.buf.code_action({ context = { only = { "source.removeUnused" } }, apply = true })
--   end, { desc = "Organize Imports", silent = true, buffer = bufNr })
--
--   -- Add Missing Imports
--   map("n", "<leader>cM", function()
--     vim.lsp.buf.code_action({ context = { only = { "source.addMissingImports" } }, apply = true })
--   end, { desc = "Add Missing Imports", silent = true, buffer = bufNr })
--
--   -- Fix All Diagnostics
--   map("n", "<leader>cD", function()
--     vim.lsp.buf.code_action({ context = { only = { "source.fixAll" } }, apply = true })
--   end, { desc = "Fix All Diagnostics", silent = true, buffer = bufNr })
-- end

--  GDScript (Godot)
lspconfig.gdscript.setup({
  cmd = { "nc", "localhost", "6005" }, -- Connect to Godot's language server
  filetypes = { "gd", "gdscript", "gdscript3" },
  root_dir = lspconfig.util.root_pattern("project.godot"),
  on_attach = function(_, bufNr)
    map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", silent = true, buffer = bufNr })
  end,
})

--  TypeScript LSP (`ts_ls`)
-- lspconfig.ts_ls.setup({
--   init_options = {
--     embeddedLanguages = { html = true },
--     plugins = {
--       {
--         name = "@vue/typescript-plugin",
--         location = "/home/d7om/.bun/install/global/node_modules/@vue/typescript-plugin/",
--         languages = { "javascript", "typescript", "vue" },
--       },
--     },
--   },
--   filetypes = { "javascript", "typescript", "vue" },
--   on_attach = on_attach,
-- })

--  LazyVim LSP Configuration
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
      },
      inlay_hints = {
        enabled = true,
        exclude = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue", "lua" },
      },
      codelens = { enabled = false },
      servers = {
        ts_ls = {
          -- enabled = vim.fn.filereadable("src/App.vue") == 1 or vim.fn.filereadable("nuxt.config.ts") == 1,
          enabled = false,
        },
        vtsls = { enabled = vim.fn.filereadable("src/App.vue") == 1 or vim.fn.filereadable("nuxt.config.ts") == 1 },
        eslint = { enabled = false },
      },
      setup = {
        ["typescript-tools"] = function(_, opts)
          LazyVim.lsp.on_attach(function()
            opts.handlers = {
              ["textDocument/publishDiagnostics"] = function(_, result, ctx, _)
                if not result.diagnostics then
                  return
                end
                local idx = 1
                while idx <= #result.diagnostics do
                  local entry = result.diagnostics[idx]
                  local formatter = require("format-ts-errors")[entry.code]
                  entry.message = formatter and formatter(entry.message) or entry.message
                  if entry.code == 80001 then
                    table.remove(result.diagnostics, idx) -- Remove specific TS diagnostics
                  else
                    idx = idx + 1
                  end
                end
                vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx)
              end,
            }
          end)
        end,
        vtsls = function(_, opts)
          LazyVim.lsp.on_attach(function()
            opts.handlers = {
              ["textDocument/publishDiagnostics"] = function(_, result, ctx, _)
                if not result.diagnostics then
                  return
                end
                local idx = 1
                while idx <= #result.diagnostics do
                  local entry = result.diagnostics[idx]
                  local formatter = require("format-ts-errors")[entry.code]
                  entry.message = formatter and formatter(entry.message) or entry.message
                  if entry.code == 80001 then
                    table.remove(result.diagnostics, idx) -- Remove specific TS diagnostics
                  else
                    idx = idx + 1
                  end
                end
                vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx)
              end,
            }
          end)
        end,
      },
    },
  },

  --  LSP Keymap Tweaks
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      local Keys = require("lazyvim.plugins.lsp.keymaps").get()
      vim.list_extend(Keys, { { "K", false } }) -- Disable conflicting hover
    end,
  },

  --  LSPSaga (Enhanced UI for LSP)
  {
    "nvimdev/lspsaga.nvim",
    enabled = true,
    config = function()
      require("lspsaga").setup({

        ui = { border = "single" },
        lightbulb = { enable = false, sign = false },
        code_action = { extend_gitsigns = false, num_shortcut = true },
        diagnostic = {
          show_layout = "float",
          max_height = 0.8,
          max_width = 0.6,
          keys = { quit = { "q", "<ESC>" } },
        },
        hover = {
          max_width = 0.6,
        },
      })
    end,
  },
}
