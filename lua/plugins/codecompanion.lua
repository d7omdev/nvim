return {
  "olimorris/codecompanion.nvim",
  version = "11.28.x",
  event = "VeryLazy",
  config = function()
    require("codecompanion").setup({
      display = {
        diff = {
          provider = "mini_diff",
        },
      },
      strategies = {
        chat = {
          roles = {
            llm = "  Copilot ",
            user = "  D7OM ",
          },
          keymaps = {
            close = {
              modes = {
                i = "<C-c>",
                n = "q",
              },
              index = 3,
              callback = "keymaps.close",
              description = "Close Chat",
            },
          },
        },
      },
      -- PROMPTS ------------------------------------------------------
      prompt_library = {
        ["Fix LSP Diagnostics"] = {
          strategy = "chat",
          description = "Fix the LSP diagnostics",
          opts = {
            default_prompt = true,
            short_name = "lsp-fix",
            modes = { "n", "v" },
            slash_cmd = "lsp-fix",
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = "system",
              content = [[You are a skilled developer who helps fix LSP diagnostics. Use the buffer context and provide solutions with code snippets where necessary.]],
              opts = {
                visible = false,
              },
            },
            {
              role = "system",
              content = function(context)
                -- Get diagnostics for the current line
                local diagnostics = require("codecompanion.helpers.actions").get_diagnostics(
                  context.start_line,
                  context.start_line, -- Target the current line
                  context.bufnr
                )

                local diagnostic_message = diagnostics[1] and diagnostics[1].message or "No diagnostics found"

                -- Include the buffer using the `#buffer` variable
                return "Diagnostic message: "
                  .. diagnostic_message
                  .. "\n\nHere is the buffer context:\n"
                  .. "#buffer:"
                  .. context.start_line - 5
                  .. "-"
                  .. context.start_line + 5
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
      },
    })

    -- Keymaps
    local map = vim.keymap.set
    map("n", "<leader>i", "<cmd>CodeCompanion<cr>", { noremap = true, silent = true, desc = "CC Inline with Buffer" })
    map("v", "<leader>i", function()
      -- Prompt user for input
      vim.ui.input({
        prompt = "Prompt: ",
      }, function(input)
        -- If input is not empty, execute CodeCompanion command
        if input and input ~= "" then
          vim.cmd("'<,'>CodeCompanion /buffer " .. input)
        end
      end)
    end, { noremap = true, silent = true, desc = "CC Inline with Prompt" })
    map(
      { "n", "v" },
      "<leader>cca",
      "<cmd>CodeCompanionActions<cr>",
      { noremap = true, silent = true, desc = "CC Actions" }
    )
    map("n", "<leader>aca", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true, desc = "CC Toggle" })
    map("v", "<leader>aca", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true, desc = "CC Toggle" })
    map("v", "ga", "<cmd>CodeCompanionAdd<cr>", { noremap = true, silent = true, desc = "CodeCompanion Add" })

    -- Prompt Library
    map("v", "<leader>cce", "", {
      callback = function()
        require("codecompanion").prompt("explain")
      end,
      noremap = true,
      silent = true,
      desc = "CC Explain",
    })
    map("v", "<leader>ccu", "", {
      callback = function()
        require("codecompanion").prompt("tests")
      end,
      noremap = true,
      silent = true,
      desc = "CC generate unit tests",
    })
    map("v", "<leader>ccf", "", {
      callback = function()
        require("codecompanion").prompt("fix")
      end,
      noremap = true,
      silent = true,
      desc = "CC fix code",
    })
    map("n", "<leader>cci", "", {
      callback = function()
        require("codecompanion").prompt("buffer")
      end,
      noremap = true,
      silent = true,
      desc = "CC insert current buffer",
    })
    map("v", "<leader>ccx", "", {
      callback = function()
        require("codecompanion").prompt("lsp-explain")
      end,
      noremap = true,
      silent = true,
      desc = "CC explain LSP diagnostics",
    })
    map("n", "<leader>ccf", "", {
      callback = function()
        require("codecompanion").prompt("lsp-fix")
      end,
      noremap = true,
      silent = true,
      desc = "CC fix LSP diagnostics",
    })
    map("n", "<leader>ccm", "", {
      callback = function()
        require("codecompanion").prompt("commit")
      end,
      noremap = true,
      silent = true,
      desc = "CC generate a commit message",
    })
    -- Expand 'cc' into 'CC' in the command line
    vim.cmd([[cab cc CC]])
  end,
}
