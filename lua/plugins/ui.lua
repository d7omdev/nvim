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
  { "tiagovla/scope.nvim", config = true },
  {
    "akinsho/bufferline.nvim",
    enabled = true,
    config = require("plugins.config.bufferline"),
  },
  {
    "mvllow/modes.nvim",
    event = "BufRead",
    enabled = true,
    config = require("plugins.config.modes"),
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    enabled = true,
    priority = 1000, -- needs to be loaded in first
    config = require("plugins.config.tiny-inline-diagnostic"),
  },

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
    enabled = false,
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
  {
    "folke/drop.nvim",
    opts = {
      filetypes = { "dashboard", "alpha", "ministarter", "snacks_dashboard" },
    },
  },
}
