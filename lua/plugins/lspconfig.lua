-- ============================================
-- LSP Configuration using vim.lsp.config (Nvim 0.11+)
-- Configs are loaded from lsp/ folder
-- ============================================

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

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local ts = require("lsp.typescript")
      opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics or {}, {
        virtual_text = false,
      })
      opts.inlay_hints = vim.tbl_deep_extend("force", opts.inlay_hints or {}, {
        enabled = true,
      })
      opts.codelens = vim.tbl_deep_extend("force", opts.codelens or {}, { enabled = false })

      opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
        ts_ls = ts.ts_ls,
        vtsls = ts.vtsls,
        eslint = ts.eslint,
        volar = ts.volar,
        cssls = require("lsp.css").cssls,
        qmlls = require("lsp.qml"),
        intelephense = require("lsp.php").intelephense,
        laravel_ls = require("lsp.laravel_ls").laravel_ls,
      })

      opts.setup = vim.tbl_deep_extend("force", opts.setup or {}, {
        ["typescript-tools"] = function(_, opts)
          opts.handlers = opts.handlers or {}
          opts.handlers["textDocument/publishDiagnostics"] = setup_ts_diagnostics
        end,

        vtsls = function(_, opts)
          opts.handlers = opts.handlers or {}
          opts.handlers["textDocument/publishDiagnostics"] = setup_ts_diagnostics
        end,

        -- GDScript custom keymaps
        gdscript = function(_, opts)
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if client and client.name == "gdscript" then
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
                  desc = "Go to definition",
                  silent = true,
                  buffer = args.buf,
                })
              end
            end,
          })
        end,

        -- QML custom setup
        qmlls = function(_, opts)
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if client and client.name == "qmlls" then
                -- Explicitly set go-to-definition keymap
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
                  desc = "Go to definition",
                  silent = true,
                  buffer = args.buf,
                })

                -- Additional QML-specific keymaps
                vim.keymap.set("n", "K", vim.lsp.buf.hover, {
                  desc = "Hover documentation",
                  silent = true,
                  buffer = args.buf,
                })
              end
            end,
          })
        end,
      })
    end,
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
          max_height = 0.8,
        },
      })

      -- Inject "Fix with Agentic AI" into lspsaga's code action picker.
      -- Patched here (eager) so it's always active before any LspAttach fires.
      local act = require("lspsaga.codeaction")
      local orig_send_request = act.send_request
      act.send_request = function(self, main_buf, options, callback)
        orig_send_request(self, main_buf, options, function(tuples, enriched_ctx)
          local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1
          local diags = vim.diagnostic.get(main_buf, { lnum = cursor_line })

          if #diags > 0 then
            table.insert(tuples, {
              "agentic",
              {
                title = "  Fix with Agentic AI",
                kind = "quickfix",
                action = function()
                  local SessionRegistry = require("agentic.session_registry")
                  SessionRegistry.get_session_for_tab_page(nil, function(session)
                    session:add_current_line_diagnostics_to_context()
                    session:_handle_input_submit(
                      "Fix the diagnostic error(s) shown in the diagnostics context."
                        .. " Analyze the error carefully and make the minimal necessary changes to resolve it."
                    )
                    session.widget:show({ focus_prompt = false })
                  end)
                end,
              },
            })
          end

          callback(tuples, enriched_ctx)
        end)
      end
    end,
  },

  -- Formatting configuration
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

      opts.formatters_by_ft["php"] = { first = { "pint", "php_cs_fixer" } }
      opts.formatters_by_ft["blade"] = { "blade-formatter" }

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
