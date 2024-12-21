vim.api.nvim_set_hl(0, "St_macro_recording", {
  fg = "#CA6169",
  bg = "#22262e",
  bold = true,
})

local utils = require("nvchad.stl.utils")

local sep_icons = utils.separators
local separators = (type("default") == "table" and "default") or sep_icons["default"]

local sep_l = separators["left"]
local sep_r = separators["right"]
local options = {

  base46 = {
    theme = "onedark", -- default theme
    hl_add = {},
    hl_override = {},
    integrations = {},
    changed_themes = {},
    transparency = false,
    theme_toggle = { "onedark", "catppuccin" },
  },

  ui = {
    cmp = {
      icons_left = false, -- only for non-atom styles!
      lspkind_text = false,
      style = "default", -- default/flat_light/flat_dark/atom/atom_colored
      format_colors = {
        tailwind = true, -- will work for css lsp too
        icon = "󱓻",
      },
    },

    telescope = { style = "borderless" }, -- borderless / bordered

    statusline = {
      enabled = true,
      theme = "default", -- default/vscode/vscode_colored/minimal
      -- default/round/block/arrow separators work only for default statusline theme
      -- round and block will work for minimal theme only
      separator_style = "default",
      order = {
        "mode",
        "file",
        "git",
        "%=",
        "lsp_msg",
        "%=",
        "diagnostics",
        "lsp",
        "copilot",
        "macro",
        "cwd",
        "cursor",
      },

      modules = {
        lsp = function()
          if rawget(vim, "lsp") then
            for _, client in ipairs(vim.lsp.get_clients()) do
              if client.attached_buffers[vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)] then
                return (vim.o.columns > 100 and "%#St_Lsp#" .. "   󰜥" .. client.name .. " ") or "   LSP "
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
          local pos = percent .. " " .. current_line .. ":" .. vim.fn.col(".")
          return "%#St_pos_sep#" .. sep_l .. "%#St_pos_icon# %#St_pos_text# " .. pos .. " "
        end,
        macro = function()
          local macro_reg = vim.fn.reg_recording()
          if macro_reg ~= "" then
            return "%#St_macro_recording#" .. " " .. macro_reg .. " "
          else
            return ""
          end
        end,
        copilot = function()
          local status = require("custom.copilot-stl").get_status()
          return "%#" .. status.hl .. "#" .. " " .. status.icon .. " "
        end,
      },
    },

    -- lazyload it when there are 1+ buffers
    tabufline = {
      enabled = true,
      lazyload = true,
      order = { "treeOffset", "buffers", "tabs", "btns" },
      modules = nil,
    },
  },

  term = {
    winopts = { number = false, relativenumber = false },
    sizes = { sp = 0.3, vsp = 0.2, ["bo sp"] = 0.3, ["bo vsp"] = 0.2 },
    float = {
      relative = "editor",
      row = 0.3,
      col = 0.25,
      width = 0.5,
      height = 0.4,
      border = "single",
    },
  },

  lsp = { signature = true },

  cheatsheet = {
    theme = "grid", -- simple/grid
    excluded_groups = { "terminal (t)", "autopairs", "Nvim", "Opens" }, -- can add group name or with mode
  },

  colorify = {
    enabled = true,
    mode = "virtual", -- fg, bg, virtual
    virt_text = "󱓻 ",
    highlight = { hex = true, lspvars = true },
  },
}

vim.keymap.set("n", "<leader>cH", "<cmd> NvCheatsheet <CR>", { desc = "Mapping cheatsheet" })
vim.keymap.set("n", "<leader>tp", "<cmd>lua require('nvchad.themes').open() <CR>", { desc = "Theme picker" })
vim.keymap.set("n", "<leader>cN", require("nvchad.lsp.renamer"), { desc = "Nvchad Rename" })

local status, chadrc = pcall(require, "chadrc")
return vim.tbl_deep_extend("force", options, status and chadrc or {})
