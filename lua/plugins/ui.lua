local g = vim.g

g.toggle_theme_icon = "   "

local txt = function(str, hl)
  str = str or ""
  local a = "%#Tb" .. hl .. "#" .. str
  return a
end

local btn = function(str, hl, func, arg)
  str = hl and txt(str, hl) or str
  arg = arg or ""
  return "%" .. arg .. "@Tb" .. func .. "@" .. str .. "%X"
end

vim.cmd("function! TbToggle_theme(a,b,c,d) \n lua require('base46').toggle_theme() \n endfunction")
vim.cmd("function! TbCloseAllBufs(a,b,c,d) \n lua Utils.close_all_buffers() \n endfunction")

return {
  {
    "catppuccin/nvim",
    event = "BufRead",
  },
  {
    "akinsho/bufferline.nvim",
    enabled = true,
    config = function()
      require("bufferline").setup({
        highlights = {
          buffer_selected = {
            bg = "#1E2122",
          },
          close_button_selected = {
            fg = "#CA6169",
            bg = "#2D3031",
          },
          separator_selected = {
            fg = "#1E2122",
            bg = "#1E2122",
          },
          modified_selected = {
            bg = "#2D3031",
          },
          indicator_selected = {
            bg = "#1E2122",
          },
          diagnostic = {
            bg = "#1E2122",
          },
          diagnostic_selected = {
            bg = "#1E2122",
          },
          hint_selected = {
            bg = "#1E2122",
          },
          hint_diagnostic_selected = {
            bg = "#1E2122",
          },
          info_selected = {
            bg = "#1E2122",
          },
          info_diagnostic_selected = {
            bg = "#1E2122",
          },
          warning_selected = {
            bg = "#1E2122",
          },
          warning_diagnostic_selected = {
            bg = "#1E2122",
          },
          error_selected = {
            bg = "#1E2122",
          },
          error_diagnostic_selected = {
            bg = "#1E2122",
          },
          pick_selected = {
            bg = "#1E2122",
          },
        },

        options = {
          separator_style = { "", "" },
          buffer_close_icon = " ",
          modified_icon = " ",
          diagnostics = "nvim_lsp", -- Enable LSP diagnostics
          diagnostics_indicator = function(_, _, diagnostics_dict, _)
            local s = ""
            for e, n in pairs(diagnostics_dict) do
              local sym = e == "error" and " " or (e == "warning" and " " or "󱩎 ")
              s = s .. sym .. n .. " "
            end
            return s
          end,
          custom_areas = {
            right = function() -- Adjust to 'left' or 'right' based on your layout
              local toggle_theme = {
                text = btn(g.toggle_theme_icon, "ThemeToggleBtn", "Toggle_theme"),
              }
              local close_all_bufs = {
                text = btn(" 󰅖 ", "CloseAllBufsBtn", "CloseAllBufs"),
              }
              return { toggle_theme, close_all_bufs }
            end,
          },
        },
      })
    end,
  },
  {
    "mvllow/modes.nvim",
    event = "BufRead",
    enabled = true,
    config = function()
      require("modes").setup({
        line_opacity = 0.2,
        set_cursorline = false,
        set_number = false,
        ignore_filetypes = { "NvimTree", "TelescopePrompt", "dashboard", "minifiles" },
      })
    end,
  },
  {
    "mistricky/codesnap.nvim",
    event = "BufRead",
    build = "make build_generator",
    keys = {
      { "<leader>cs", "", mode = "x", desc = "+Code Snap" },
      { "<leader>csc", "<cmd>CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
      { "<leader>css", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "Save selected code snapshot in ~/Pictures" },
    },
    opts = {
      save_path = "~/Pictures/CodeSnap/",
      has_breadcrumbs = true,
      bg_theme = "grape",
      code_font_family = "JetBrainsMono Nerd Font",
      watermark = "",
    },
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    enabled = false,
    priority = 1000, -- needs to be loaded in first
    config = function()
      require("tiny-inline-diagnostic").setup({
        options = {
          show_source = true,
          use_icons_from_diagnostic = true,
          show_all_diags_on_cursorline = true,
        },
      })
    end,
  },
  -- {
  --   "Bekaboo/dropbar.nvim",
  --   event = "BufRead",
  --   config = function()
  --     local dropbar_api = require("dropbar.api")
  --     vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
  --     vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
  --     vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
  --   end,
  -- },
  {
    "rachartier/tiny-glimmer.nvim",
    branch = "main",
    event = "TextYankPost",
    opts = {
      default_animation = "fade",
      overwrite = {
        search = {
          enabled = false,
          default_animation = "pulse",
          next_mapping = "nzzzv",
          prev_mapping = "Nzzzv",
        },
        paste = {
          enabled = true,
          default_animation = "reverse_fade",
          paste_mapping = "p",
          Paste_mapping = "P",
        },
        undo = {
          enabled = true,
          default_animation = {
            name = "fade",
          },
          undo_mapping = "u",
        },
        redo = {
          enabled = true,
          default_animation = {
            name = "reverse_fade",
          },
          redo_mapping = "<c-r>",
        },
      },
    },
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    config = function()
      vim.diagnostic.config({ virtual_lines = { only_current_line = true } })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lazy", "text" },
        callback = function()
          vim.diagnostic.config({ virtual_lines = false })
        end,
      })
      require("lsp_lines").setup()
    end,
  },
}
