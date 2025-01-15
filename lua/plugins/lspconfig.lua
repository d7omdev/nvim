local lspconfig = require("lspconfig")

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

-- Add the Tailwind CSS LSP configuration
lspconfig.tailwindcss.setup({
  filetypes = { "typescript", "typescriptreact" },
  root_dir = function(fname)
    -- Check if the project has tailwind.config.js
    local root = vim.fs.find(".git", { path = vim.fn.getcwd(), upward = true })[1] or vim.fn.getcwd()
    return vim.fn.glob(root .. "/tailwind.config.js") ~= "" and root or nil
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
          "typescript",
          "typescriptreact",
          "javascript",
          "javascriptreact",
          "vue",
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
          enabled = true,
        },
        eslint = {
          enabled = true,
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
        eslint = function(_, opts)
          local function get_client(buf)
            return LazyVim.lsp.get_clients({ name = "eslint", bufnr = buf })[1]
          end

          local formatter = LazyVim.lsp.formatter({
            name = "eslint: lsp",
            primary = false,
            priority = 200,
            filter = "eslint",
          })

          -- Use EslintFixAll on Neovim < 0.10.0
          if not pcall(require, "vim.lsp._dynamic") then
            formatter.name = "eslint: EslintFixAll"
            formatter.sources = function(buf)
              local client = get_client(buf)
              return client and { "eslint" } or {}
            end
            formatter.format = function(buf)
              local client = get_client(buf)
              client.flags = { allow_incremental_sync = false, debounce_text_changes = 1000, exit_timeout = 1500 }
              if client then
                local diag = vim.diagnostic.get(buf, { namespace = vim.lsp.diagnostic.get_namespace(client.id) })
                if #diag > 0 then
                  vim.cmd("EslintFixAll")
                end
              end
            end
          end
          -- register the formatter with LazyVim
          LazyVim.format.register(formatter)
        end,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
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
