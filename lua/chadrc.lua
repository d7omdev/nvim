local utils = require("nvchad.stl.utils")
local sep_icons = utils.separators
local separators = sep_icons["default"]
local sep_l = separators["left"]

local lazy_status = require("lazy.status")

local options = {
  base46 = {
    theme = "gruvchad",
    hl_add = {},
    integrations = {},
    changed_themes = {},
    transparency = true,
    theme_toggle = { "gruvchad", "catppuccin" },
    hl_override = {},
  },
}

-- Ensure highlight override is set only if there are updates
if lazy_status.has_updates() then
  options.base46.hl_override.St_cwd_sep = { bg = Snacks.util.color("St_EmptySpace", "bg") }
else
  options.base46.hl_override = {}
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
    separator_style = "default", -- default/round/block/arrow
    order = {
      "mode",
      "file",
      "git",
      "%=",
      "diagnostics",
      "live_server",
      "lsp",
      "copilot",
      "macro",
      "updates",
      "cwd",
      "cursor",
    },

    modules = {
      lsp = function()
        if not rawget(vim, "lsp") then
          return ""
        end

        local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
        local clients = vim.lsp.get_clients({ bufnr = bufnr })

        if #clients == 0 then
          return ""
        end

        -- Check if expanded mode is enabled
        local expanded = vim.g.lsp_status_expanded or false
        local output = "%#St_Lsp#  "

        -- Function to shorten client names
        local function format_client_name(name)
          if name == "typescript-tools" then
            return "ts-tools"
          elseif name == "tailwind-tools" then
            return "tw-tools"
          else
            return name
          end
        end

        if expanded then
          local names = {}
          for _, client in ipairs(clients) do
            table.insert(names, format_client_name(client.name))
          end
          output = output .. " " .. table.concat(names, ", ") .. " "
        else
          local main_client = format_client_name(clients[1].name)
          for _, client in ipairs(clients) do
            if client.name == "typescript-tools" then
              main_client = format_client_name(client.name)
              break
            end
          end
          output = output .. "  󰜥" .. main_client .. " "
        end

        -- Make the entire component clickable to toggle expanded view
        return "%@v:lua.ToggleLspStatus@" .. output .. "%X"
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
          options.base46.hl_override.St_cwd_sep = { bg = Snacks.util.color("St_EmptySpace", "bg") }
          local updates_count = lazy_status.updates():match("%d+") or "0"
          return ("%#St_Updates_sep#" .. sep_l .. "%#St_Updates_Icon# %#Updates# " .. updates_count .. " ")
          -- return ("%#St_Updates_Icon# %#Updates#" .. updates_count .. " ")
        end
        options.base46.hl_override.St_cwd_sep = {}
        return ""
      end,

      live_server = function()
        if vim.bo.filetype ~= "html" then
          return ""
        end

        local server_active = vim.g.live_server_active or false
        local output = "%#St_HtmlServer#"

        if server_active then
          -- Server is running, show stop icon
          output = output .. "  󰒏"
          -- Make clickable to stop server
          return "%@v:lua.StopLiveServer@" .. output .. "%X"
        else
          -- Server not running, show start icon
          output = output .. "  󰒋"
          -- Make clickable to start server
          return "%@v:lua.StartLiveServer@" .. output .. "%X"
        end
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
local map = vim.keymap.set
map("n", "<leader>cH", "<cmd> NvCheatsheet <CR>", { desc = "Mapping cheatsheet" })
map("n", "<leader>tp", function()
  require("nvchad.themes").open()
end, { desc = "Theme picker" })
map("n", "<leader>cN", require("nvchad.lsp.renamer"), { desc = "Nvchad Rename" })
map("n", "<leader>tT", function()
  require("base46").toggle_transparency()
end, { desc = "Toggle transparency" })

-- Merge with external config if exists
local status, chadrc = pcall(require, "chadrc")
if status then
  vim.tbl_deep_extend("force", options, chadrc)
end

return options
