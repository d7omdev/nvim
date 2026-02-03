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

return function()
  require("bufferline").setup({
    highlights = {
      buffer_selected = {
        bg = "#1E2122",
      },
      duplicate_selected = {
        bg = "#1E2122",
        bold = true,
      },
      duplicate_visible = {
        bg = "#1E2122",
        bold = false,
        italic = false,
      },
      duplicate = {
        bold = false,
        italic = false,
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
      buffer_close_icon = " ",
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
        right = function()
          local g = vim.g
          local btn = function(str, hl, func, arg)
            str = hl and txt(str, hl) or str
            arg = arg or ""
            return "%" .. arg .. "@Tb" .. func .. "@" .. str .. "%X"
          end

          local toggle_theme = {
            text = btn(g.toggle_theme_icon, "ThemeToggleBtn", "Toggle_theme"),
          }
          local close_all_bufs = {
            text = btn(" 󰅖 ", "CloseAllBufsBtn", "CloseAllBufs"),
          }
          if vim.bo.filetype == "snacks_dashboard" then
            return {}
          else
            return { toggle_theme, close_all_bufs }
          end
        end,
      },
    },
  })
end
