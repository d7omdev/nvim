local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")

-- Set default LSP config options
local default = lspconfig.util.default_config
default.flags = vim.tbl_deep_extend("force", default.flags or {}, {
  debounce_text_changes = 300, -- milliseconds
})

-- TS diagnostic handler function (reused by multiple servers)
local function setup_ts_diagnostics(_, result, ctx, _)
  if not result.diagnostics then
    return
  end

  local idx = 1
  while idx <= #result.diagnostics do
    local entry = result.diagnostics[idx]
    local formatter = require("format-ts-errors")[entry.code]
    entry.message = formatter and formatter(entry.message) or entry.message

    -- Remove specific TS diagnostics (code 80001)
    if entry.code == 80001 then
      table.remove(result.diagnostics, idx)
    else
      idx = idx + 1
    end
  end

  vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx)
end

-- Configure GDScript (Godot) LSP
lspconfig.gdscript.setup({
  cmd = { "nc", "localhost", "6005" },
  filetypes = { "gd", "gdscript", "gdscript3" },
  root_dir = lspconfig.util.root_pattern("project.godot"),
  on_attach = function(_, bufNr)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
      desc = "Go to definition",
      silent = true,
      buffer = bufNr,
    })
  end,
})

-- lspconfig.qmlls.setup({
--   cmd = { "qmlls6" },
--   filetypes = { "qmljs", "qml" },
--   root_dir = function(fname)
--     return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
--   end,
--   single_file_support = true,
-- })

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
      },
      inlay_hints = {
        enabled = true,
        exclude = { "typescriptreact", "javascript", "javascriptreact", "vue", "lua" },
      },
      codelens = { enabled = false },
      servers = {
        ts_ls = {
          enabled = false,
        },
        vtsls = {
          enabled = vim.fn.filereadable("src/App.vue") == 1 or vim.fn.filereadable("nuxt.config.ts") == 1,
        },
        eslint = {
          enabled = false,
          settings = {
            format = { enable = true },
          },
        },
        volar = {
          init_options = {
            vue = {
              hybridMode = true,
            },
          },
        },
      },
      setup = {
        ["typescript-tools"] = function(_, opts)
          LazyVim.lsp.on_attach(function()
            opts.handlers = {
              ["textDocument/publishDiagnostics"] = setup_ts_diagnostics,
            }
          end)
        end,

        vtsls = function(_, opts)
          LazyVim.lsp.on_attach(function()
            opts.handlers = {
              ["textDocument/publishDiagnostics"] = setup_ts_diagnostics,
            }
          end)
        end,
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", has = "definition" },
          },
        },
      },
    },
  },

  -- LSPSaga Configuration
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

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters = opts.formatters or {}

      local prettier_filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "json",
        "css",
        "scss",
        "less",
        "html",
        "yaml",
      }

      for _, ft in ipairs(prettier_filetypes) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], "prettierd")
      end

      opts.formatters.prettierd = {
        condition = function(self, ctx)
          return vim.fs.find(
            { ".prettierrc", ".prettierrc.js", ".prettierrc.json", "prettier.config.js" },
            { path = ctx.filename, upward = true }
          )[1] or vim.g.lazyvim_prettier_needs_config ~= true
        end,
        options = {
          ["vue"] = {
            indent_script_and_style = false,
          },
        },
      }
    end,
  },
}
