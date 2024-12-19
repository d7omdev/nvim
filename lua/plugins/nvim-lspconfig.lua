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
    opts = function()
      local ret = {
        diagnostics = {
          underline = true,
          update_in_insert = false,
          -- virtual_text = {
          --   spacing = 4,
          --   source = "if_many",
          --   prefix = "■",
          --   -- prefix = "icons",
          -- },
          virtual_text = false,
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
              [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
              [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
              [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
            },
          },
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
        document_highlight = {
          enabled = true,
        },
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        servers = {
          jsonls = {
            -- lazy-load schemastore when needed
            on_new_config = function(new_config)
              new_config.settings.json.schemas = new_config.settings.json.schemas or {}
              vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
            end,
            settings = {
              json = {
                format = {
                  enable = true,
                },
                validate = { enable = true },
              },
            },
          },
          lua_ls = {
            settings = {
              Lua = {
                workspace = {
                  checkThirdParty = false,
                },
                codeLens = {
                  enable = true,
                },
                completion = {
                  callSnippet = "Replace",
                },
                doc = {
                  privateName = { "^_" },
                },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
          tsserver = {
            enabled = false,
          },
          vtsls = {
            enabled = true,
            filetypes = {
              "javascript",
              "javascriptreact",
              "typescript",
              "typescriptreact",
            },
            settings = {
              complete_function_calls = true,
              vtsls = {
                enableMoveToFileCodeAction = true,
                autoUseWorkspaceTsdk = true,
                experimental = {
                  completion = {
                    enableServerSideFuzzyMatch = true,
                    enableAutoImport = true,
                    enableCallHierarchy = true,
                  },
                },
              },
              typescript = {
                updateImportsOnFileMove = { enabled = "always" },
                suggest = {
                  completeFunctionCalls = true,
                },
                inlayHints = {
                  parameterNames = { enabled = "literals" },
                  enumMemberValues = { enabled = true },
                  functionLikeReturnTypes = { enabled = true },
                  parameterTypes = { enabled = true },
                  propertyDeclarationTypes = { enabled = true },
                  variableTypes = { enabled = false },
                },
              },
            },
            keys = {
              {
                "gD",
                function()
                  local params = vim.lsp.util.make_position_params()
                  LazyVim.lsp.execute({
                    command = "typescript.goToSourceDefinition",
                    arguments = { params.textDocument.uri, params.position },
                    open = true,
                  })
                end,
                desc = "Goto Source Definition",
              },
              {
                "gR",
                function()
                  LazyVim.lsp.execute({
                    command = "typescript.findAllFileReferences",
                    arguments = { vim.uri_from_bufnr(0) },
                    open = true,
                  })
                end,
                desc = "File References",
              },
              {
                "<leader>co",
                LazyVim.lsp.action["source.organizeImports"],
                desc = "Organize Imports",
              },
              {
                "<leader>cM",
                LazyVim.lsp.action["source.addMissingImports.ts"],
                desc = "Add missing imports",
              },
              {
                "<leader>cu",
                LazyVim.lsp.action["source.removeUnused.ts"],
                desc = "Remove unused imports",
              },
              {
                "<leader>cD",
                LazyVim.lsp.action["source.fixAll.ts"],
                desc = "Fix all diagnostics",
              },
              {
                "<leader>cV",
                function()
                  LazyVim.lsp.execute({ command = "typescript.selectTypeScriptVersion" })
                end,
                desc = "Select TS workspace version",
              },
            },
          },
        },
        setup = {
          tsserver = function()
            return true
          end,
          vtsls = function(_, opts)
            LazyVim.lsp.on_attach(function(client, buffer)
              client.commands["_typescript.moveToFileRefactoring"] = function(command, ctx)
                local action, uri, range = unpack(command.arguments)

                local function move(newf)
                  client.request("workspace/executeCommand", {
                    command = command.command,
                    arguments = { action, uri, range, newf },
                  })
                end

                local fname = vim.uri_to_fname(uri)
                client.request("workspace/executeCommand", {
                  command = "typescript.tsserverRequest",
                  arguments = {
                    "getMoveToRefactoringFileSuggestions",
                    {
                      file = fname,
                      startLine = range.start.line + 1,
                      startOffset = range.start.character + 1,
                      endLine = range["end"].line + 1,
                      endOffset = range["end"].character + 1,
                    },
                  },
                }, function(_, result)
                  local files = result.body.files
                  table.insert(files, 1, "Enter new path...")
                  vim.ui.select(files, {
                    prompt = "Select move destination:",
                    format_item = function(f)
                      return vim.fn.fnamemodify(f, ":~:.")
                    end,
                  }, function(f)
                    if f and f:find("^Enter new path") then
                      vim.ui.input({
                        prompt = "Enter move destination:",
                        default = vim.fn.fnamemodify(fname, ":h") .. "/",
                        completion = "file",
                      }, function(newf)
                        return newf and move(newf)
                      end)
                    elseif f then
                      move(f)
                    end
                  end)
                end)
              end
            end, "vtsls")
            opts.settings.javascript =
              vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})

            opts.handlers = {
              ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
                if result.diagnostics == nil then
                  return
                end

                local idx = 1
                while idx <= #result.diagnostics do
                  local entry = result.diagnostics[idx]

                  local formatter = require("format-ts-errors")[entry.code]
                  entry.message = formatter and formatter(entry.message) or entry.message

                  if entry.code == 80001 then
                    table.remove(result.diagnostics, idx)
                  else
                    idx = idx + 1
                  end
                end

                vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
              end,
            }
          end,
        },
      }
      return ret
    end,
  },
}
