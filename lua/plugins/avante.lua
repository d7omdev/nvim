return {
  "yetone/avante.nvim",
  enabled = false,
  build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    or "make",
  event = "VeryLazy",
  version = false,

  opts = {

    instructions_file = "avante.md",

    provider = "claude-code",
    behaviour = {
      auto_suggestions = false, -- Experimental stage

      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = true,
      auto_approve_tool_permissions = true,
      enable_fastapply = true, -- Enable Fast Apply feature
      -- Examples:
      -- auto_approve_tool_permissions = false,                -- Show permission prompts for all tools
      -- auto_approve_tool_permissions = {"bash", "str_replace"}, -- Auto-approve specific tools only
      ---@type "popup" | "inline_buttons"
      confirmation_ui_style = "inline_buttons",
      --- Whether to automatically open files and navigate to lines when ACP agent makes edits
      ---@type boolean
      acp_follow_agent_locations = true,
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",

    "nvim-mini/mini.pick",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
    "ibhagwan/fzf-lua",
    "stevearc/dressing.nvim",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
    "zbirenbaum/copilot.lua",
    {

      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {

        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },

          use_absolute_path = true,
        },
      },
    },
    {

      "MeanderingProgrammer/render-markdown.nvim",
      enabled = false,
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
