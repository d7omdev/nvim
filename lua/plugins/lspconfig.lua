local lspconfig = require("lspconfig")

-- Configure GDScript LSP
lspconfig.gdscript.setup({
  cmd = { "nc", "localhost", "6005" }, -- Connect to Godot's language server
  filetypes = { "gd", "gdscript", "gdscript3" }, -- GDScript file types
  root_dir = lspconfig.util.root_pattern("project.godot"), -- Root is the Godot project
  on_attach = function(client, bufnr)
    -- Keybindings for LSP functionality
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts) -- Go to definition
  end,
})

-- Configuration for LazyVim's LSP settings
return {
  {
    "neovim/nvim-lspconfig",
    --- @class lspconfig
    opts = {
      diagnostics = {
        virtual_text = false,
      },
      inlay_hints = {
        enabled = true,
        exclude = {
          "typescript",
          "typescriptreact",
          "javascript",
          "javascriptreact",
          -- "vue",
        },
      },
      codelens = {
        enabled = false,
      },
      servers = {
        tsserver = {
          enabled = false,
        },
        ts_ls = {
          enabled = false,
        },
        vtsls = {
          enabled = vim.fn.filereadable("vite.config.ts") == 1 or vim.fn.filereadable("src/App.vue") == 1,
        },
        eslint = {
          enabled = false,
        },
      },
      setup = {
        vtsls = function(_, opts)
          LazyVim.lsp.on_attach(function()
            opts.handlers = {
              ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
                if result.diagnostics == nil then
                  return
                end
                local max_width = 80
                local idx = 1
                while idx <= #result.diagnostics do
                  local entry = result.diagnostics[idx]
                  local formatter = require("format-ts-errors")[entry.code]
                  entry.message = formatter and formatter(entry.message) or entry.message

                  -- Wrap the message text
                  entry.message = vim.lsp.util.format_lines(vim.lsp.util.wrap(entry.message, max_width))

                  if entry.code == 80001 then
                    table.remove(result.diagnostics, idx)
                  else
                    idx = idx + 1
                  end
                end
                vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
              end,
            }
          end)
        end,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      local Keys = require("lazyvim.plugins.lsp.keymaps").get()
      vim.list_extend(Keys, {
        { "K", false },
      })
    end,
  },
  {
    "nvimdev/lspsaga.nvim",
    enabled = true,
    config = function()
      require("lspsaga").setup({
        ui = {
          border = "single",
        },
        lightbulb = {
          enable = false,
          sign = false,
        },
        code_action = { extend_gitsigns = false, num_shortcut = true },
        diagnostic = {
          show_layout = "float",
          max_height = 0.8,
          max_width = 0.1,
          keys = {
            quit = { "q", "<ESC>" },
          },
        },
      })
    end,
  },
}
