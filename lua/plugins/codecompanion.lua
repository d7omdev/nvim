return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp", -- Optional: For using slash commands and variables in the chat buffer
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
        },
        inline = {
          adapter = "copilot",
        },
        agent = {
          adapter = "copilot",
        },
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
      slash_commands = {
        ["buffer"] = {
          callback = "helpers.slash_commands.buffer",
          description = "Insert open buffers",
          opts = {
            icon = "",
            contains_code = true,
            provider = "fzf_lua", -- default|telescope|mini_pick|fzf_lua
          },
        },
        ["file"] = {
          callback = "helpers.slash_commands.file",
          description = "Insert a file",
          opts = {
            icon = "",
            contains_code = true,
            max_lines = 1000,
            provider = "fzf_lua", -- telescope|mini_pick|fzf_lua
          },
        },
        ["now"] = {
          callback = "helpers.slash_commands.now",
          description = "Insert the current date and time",
          opts = {
            contains_code = false,
          },
        },
        ["symbols"] = {
          callback = "helpers.slash_commands.symbols",
          description = "Insert symbols for the active buffer",
          opts = {
            contains_code = true,
          },
        },
      },
      -- PRE-DEFINED PROMPTS ------------------------------------------------------
      prompt_library = {
        ["Explain"] = {
          strategy = "chat",
          description = "Explain how code in a buffer works",
          opts = {
            index = 4,
            default_prompt = true,
            short_name = "explain",
            modes = { "v" },
            slash_cmd = "explain",
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = "system",
              content = [[When asked to explain code, follow these steps:

    1. Identify the programming language.
    2. Describe the purpose of the code and reference core concepts from the programming language.
    3. Explain each function or significant block of code, including parameters and return values.
    4. Highlight any specific functions or methods used and their roles.
    5. Provide context on how the code fits into a larger application if applicable.]],
              opts = {
                visible = false,
              },
            },
            {
              role = "user",
              content = function(context)
                local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                return "Please explain this code:\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["Unit Tests"] = {
          strategy = "chat",
          description = "Generate unit tests for the selected code",
          opts = {
            index = 5,
            default_prompt = true,
            short_name = "tests",
            modes = { "v" },
            slash_cmd = "tests",
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = "system",
              content = [[When generating unit tests, follow these steps:

    1. Identify the programming language.
    2. Identify the purpose of the function or module to be tested.
    3. List the edge cases and typical use cases that should be covered in the tests and share the plan with the user.
    4. Generate unit tests using an appropriate testing framework for the identified programming language.
    5. Ensure the tests cover:
          - Normal cases
          - Edge cases
          - Error handling (if applicable)
    6. Provide the generated unit tests in a clear and organized manner without additional explanations or chat.]],
              opts = {
                visible = false,
              },
            },
            {
              role = "user",
              content = function(context)
                local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                return "Please generate unit tests for this code:\n\n```"
                  .. context.filetype
                  .. "\n"
                  .. code
                  .. "\n```\n\n"
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["Fix code"] = {
          strategy = "chat",
          description = "Fix the selected code",
          opts = {
            index = 6,
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
        ["Buffer selection"] = {
          strategy = "inline",
          description = "Send the current buffer to the LLM as part of an inline prompt",
          opts = {
            index = 7,
            modes = { "n" },
            default_prompt = true,
            short_name = "buffer",
            slash_cmd = "buffer",
            auto_submit = true,
            user_prompt = true,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = "system",
              content = function(context)
                return "I want you to act as a senior "
                  .. context.filetype
                  .. " developer. I will ask you specific questions and I want you to return raw code only (no codeblocks and no explanations). If you can't respond with code, respond with nothing."
              end,
              opts = {
                visible = false,
                tag = "system_tag",
              },
            },
            {
              role = "user",
              content = function(context)
                local buf_utils = require("codecompanion.utils.buffers")

                return " \n\n```" .. context.filetype .. "\n" .. buf_utils.get_content(context.bufnr) .. "\n```\n\n"
              end,
              opts = {
                contains_code = true,
                visible = false,
              },
            },
            {
              role = "user",
              condition = function(context)
                return context.is_visual
              end,
              content = function(context)
                local selection =
                  require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
                return "And this is some that relates to my question:\n\n```"
                  .. context.filetype
                  .. "\n"
                  .. selection
                  .. "\n```\n\n"
              end,
              opts = {
                contains_code = true,
                visible = true,
                tag = "visual",
              },
            },
          },
        },
        ["Explain LSP Diagnostics"] = {
          strategy = "chat",
          description = "Explain the LSP diagnostics for the selected code",
          opts = {
            index = 8,
            default_prompt = true,
            short_name = "lsp-explain",
            modes = { "v" },
            slash_cmd = "lsp",
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = "system",
              content = [[You are an expert coder and helpful assistant who can help debug code diagnostics, such as warning and error messages. When appropriate, give solutions with code snippets as fenced codeblocks with a language identifier to enable syntax highlighting.]],
              opts = {
                visible = false,
              },
            },
            {
              role = "user",
              content = function(context)
                local diagnostics = require("codecompanion.helpers.actions").get_diagnostics(
                  context.start_line,
                  context.end_line,
                  context.bufnr
                )

                local concatenated_diagnostics = ""
                for i, diagnostic in ipairs(diagnostics) do
                  concatenated_diagnostics = concatenated_diagnostics
                    .. i
                    .. ". Issue "
                    .. i
                    .. "\n  - Location: Line "
                    .. diagnostic.line_number
                    .. "\n  - Severity: "
                    .. diagnostic.severity
                    .. "\n  - Message: "
                    .. diagnostic.message
                    .. "\n"
                end

                return "The programming language is "
                  .. context.filetype
                  .. ". This is a list of the diagnostic messages:\n\n"
                  .. concatenated_diagnostics
              end,
            },
            {
              role = "user",
              content = function(context)
                return "This is the code, for context:\n\n"
                  .. "```"
                  .. context.filetype
                  .. "\n"
                  .. require("codecompanion.helpers.actions").get_code(
                    context.start_line,
                    context.end_line,
                    { show_line_numbers = true }
                  )
                  .. "\n```\n\n"
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
            index = 8,
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
            index = 9,
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
      },
      -- DISPLAY OPTIONS ----------------------------------------------------------
      display = {
        diff = {
          provider = "mini_diff",
        },
        action_palette = {
          width = 95,
          height = 10,
        },
        chat = {
          window = {
            layout = "vertical", -- float|vertical|horizontal|buffer
            border = "single",
            height = 0.8,
            width = 0.45,
            relative = "editor",
            opts = {
              breakindent = true,
              cursorcolumn = false,
              cursorline = false,
              foldcolumn = "0",
              linebreak = true,
              list = false,
              signcolumn = "no",
              spell = false,
              wrap = true,
            },
          },
          intro_message = "Press ? for options",

          separator = "─", -- The separator between the different messages in the chat buffer
          show_settings = false, -- Show LLM settings at the top of the chat buffer?
          show_token_count = true, -- Show the token count for each response?
          ---@param tokens number
          ---@param adapter CodeCompanion.Adapter
          token_count = function(tokens, adapter) -- The function to display the token count
            return " (" .. tokens .. " tokens)"
          end,
        },
        inline = {
          -- If the inline prompt creates a new buffer, how should we display this?
          layout = "vertical", -- vertical|horizontal|buffer
          diff = {
            enabled = true,
            -- mini_diff is using inline diff in the same buffer but requires the plugin to be installed: https://github.com/echasnovski/mini.diff
            diff_method = "mini_diff", -- default|mini_diff
            close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
            layout = "vertical", -- vertical|horizontal
            opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
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
    map("n", "<leader>cca", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true, desc = "CC Actions" })
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
