local utils = require("nvchad.stl.utils")
local sep_icons = utils.separators
local separators = sep_icons["default"]
local sep_l = separators["left"]

local lazy_status = require("lazy.status")

local options = {
  base46 = {
    theme = "monochrome", -- default theme
    hl_add = {},
    integrations = {},
    changed_themes = {},
    transparency = false,
    theme_toggle = { "monochrome", "catppuccin" },
    hl_override = {},
  },
}

-- Ensure highlight override is set only if there are updates
if lazy_status.has_updates() then
  options.base46.hl_override.St_cwd_sep = { bg = Snacks.util.color("St_EmptySpace", "bg") }
end

options.ui = {
  cmp = {
    icons_left = false, -- only for non-atom styles!
    lspkind_text = false,
    style = "default", -- default/flat_light/flat_dark/atom/atom_colored
    format_colors = {
      tailwind = true, -- works for CSS LSP too
      icon = "󱓻",
    },
  },

  telescope = { style = "borderless" }, -- borderless / bordered

  statusline = {
    enabled = true,
    theme = "default", -- default/vscode/vscode_colored/minimal
    separator_style = "default",
    order = {
      "mode",
      "file",
      "git",
      "%=",
      "diagnostics",
      "lsp",
      "copilot",
      "macro",
      "updates",
      "cwd",
      "cursor",
    },

    modules = {
      lsp = function()
        if rawget(vim, "lsp") then
          for _, client in ipairs(vim.lsp.get_clients()) do
            if client.attached_buffers[vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)] then
              return (vim.o.columns > 100 and "%#St_Lsp#   󰜥" .. client.name .. " ") or " "
            end
          end
        end
        return ""
      end,

      cursor = function()
        local current_line = vim.fn.line(".")
        local total_lines = vim.fn.line("$")
        local prec = math.floor((current_line / total_lines) * 100 + 0.5)
        local percent = (current_line == 1) and "Top" or (current_line == total_lines and "Bot" or prec .. "%%")
        return (
          "%#St_pos_sep#"
          .. sep_l
          .. "%#St_pos_icon# %#St_pos_text# "
          .. percent
          .. " "
          .. current_line
          .. ":"
          .. vim.fn.col(".")
          .. " "
        )
      end,

      macro = function()
        local macro_reg = vim.fn.reg_recording()
        return macro_reg ~= "" and ("%#St_macro_recording# " .. macro_reg .. " ") or ""
      end,

      copilot = function()
        local status = require("custom.copilot-stl").get_status()
        return "%#" .. status.hl .. "#" .. " " .. status.icon .. " "
      end,

      updates = function()
        if lazy_status.has_updates() then
          local updates_count = lazy_status.updates():match("%d+") or "0"
          return ("%#St_Updates_sep#" .. sep_l .. "%#St_Updates_Icon# %#Updates# " .. updates_count .. " ")
        end
        return ""
      end,
    },
  },

  tabufline = {
    enabled = true,
    lazyload = true,
    order = { "treeOffset", "buffers", "tabs", "btns" },
    modules = nil,
  },
}

options.colorify = {
  enabled = true,
  mode = "virtual", -- fg, bg, virtual
  virt_text = "󱓻 ",
  highlight = { hex = true, lspvars = true },
}

-- Keybindings
vim.keymap.set("n", "<leader>cH", "<cmd> NvCheatsheet <CR>", { desc = "Mapping cheatsheet" })
vim.keymap.set("n", "<leader>tp", function()
  require("nvchad.themes").open()
end, { desc = "Theme picker" })
vim.keymap.set("n", "<leader>cN", require("nvchad.lsp.renamer"), { desc = "Nvchad Rename" })

-- Merge with external config if exists
local status, chadrc = pcall(require, "chadrc")
if status then
  vim.tbl_deep_extend("force", options, chadrc)
end

return options
