return {
  "olimorris/codecompanion.nvim",
  version = "11.28.x",
  event = "VeryLazy",
  dependencies = {
    {
      "echasnovski/mini.diff",
      version = "*",
      config = function()
        require("mini.diff").setup({
          -- Options for how hunks are visualized
          view = {
            -- Visualization style. Possible values are 'sign' and 'number'.
            -- Default: 'number' if line numbers are enabled, 'sign' otherwise.
            style = vim.go.number and "number" or "sign",
            -- Signs used for hunks with 'sign' view
            signs = { add = "▒", change = "▒", delete = "▒" },
            -- Priority of used visualization extmarks
            priority = 199,
          },
        })
      end,
    },
    {
      "stevearc/dressing.nvim",
      opts = {},
    },
    "nvim-telescope/telescope.nvim",
  },
  opts = { send_code = true },
  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "copilot",
          roles = {
            llm = "  Copilot ",
            user = "  D7OM ",
          },
          slash_commands = {
            ["buffer"] = {
              opts = {
                contains_code = true,
                provider = "mini_pick",
              },
            },
            ["file"] = {
              opts = {
                contains_code = true,
                max_lines = 1000,
                provider = "mini_pick",
              },
            },
            ["help"] = {
              opts = {
                contains_code = false,
                provider = "mini_pick",
              },
            },
          },
        },
      },
      inline = {
        adapter = "copilot",
      },
      agent = {
        adapter = "copilot",
      },

      keymaps = {
        close = {
          modes = {
            n = "<C-c>",
            i = "q",
          },
          index = 3,
          callback = "keymaps.close",
          description = "Close Chat",
        },
      },

      -- PROMPTS ------------------------------------------------------
      prompt_library = {
        ["Fix code"] = {
          strategy = "chat",
          description = "Fix the selected code",
          opts = {
            default_prompt = true,
            short_name = "fix",
            modes = { "v" },
            slash_cmd = "fix",
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = "system",
              content = [[When asked to fix code, follow these steps:

    1. **Identify the Issues**: Carefully read the provided code and identify any potential issues or improvements.
    2. **Plan the Fix**: Describe the plan for fixing the code in pseudocode, detailing each step.
    3. **Implement the Fix**: Write the corrected code in a single code block.
    4. **Explain the Fix**: Briefly explain what changes were made and why.

    Ensure the fixed code:

    - Includes necessary imports.
    - Handles potential errors.
    - Follows best practices for readability and maintainability.
    - Is formatted correctly.

    Use Markdown formatting and include the programming language name at the start of the code block.]],
              opts = {
                visible = false,
              },
            },
            {
              role = "user",
              content = function(context)
                local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                return "Please fix the selected code:\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["Fix LSP Diagnostics"] = {
          strategy = "chat",
          description = "Fix the LSP diagnostics",
          opts = {
            default_prompt = true,
            short_name = "lsp-fix",
            modes = { "n", "v" },
            slash_cmd = "buffer",
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
              role = "user",
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
                  .. context.start_line
                  .. "-"
                  .. context.start_line + 10
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["Generate a Commit Message"] = {
          strategy = "chat",
          description = "Generate a commit message",
          opts = {
            default_prompt = true,
            short_name = "commit",
            slash_cmd = "commit",
            auto_submit = true,
          },
          prompts = {
            {
              role = "user",
              content = function()
                return "You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me:"
                  .. "\n\n```\n"
                  .. vim.fn.system("git diff")
                  .. "\n```"
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["Comment "] = {
          strategy = "inline",
          description = "Comment the selected code",
          opts = {
            modes = { "v" },
            default_prompt = true,
            short_name = "comment",
            slash_cmd = "comment",
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = "system",
              content = [[When asked to comment code, follow these steps: 1. Identify the programming language. 2. Describe the purpose of the code and reference core concepts from the programming language. 3. Explain each function or significant block of code, including parameters and return values. 4. Highlight any specific functions or methods used and their roles. 5. Provide context on how the code fits into a larger application if applicable.]],
              opts = {
                visible = false,
              },
            },
            {
              role = "user",
              content = function(context)
                local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
                return "Please comment this code:\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
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
    map("n", "<leader>a", "", { noremap = true, silent = true, desc = "+AI" })
    map("v", "<leader>a", "", { noremap = true, silent = true, desc = "+AI" })
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
    -- map("v", "<leader>af", "", {
    --   callback = function()
    --     require("codecompanion").prompt("lsp-explain")
    --   end,
    --   noremap = true,
    --   silent = true,
    --   desc = "CC fix LSP diagnostics",
    -- })
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
