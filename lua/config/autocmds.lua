-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Automatically sort classes in a .tsx file on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.tsx" },
  callback = function()
    local lsp = require("tailwind-tools.lsp")
    lsp.sort_classes(true)
  end,
})

-- Auto save on focus lost, mode change, text change, and buffer enter
vim.api.nvim_create_autocmd(
  { "FocusLost", "TextChanged", "BufEnter" },
  { desc = "autosave", pattern = "*", command = "silent! update" }
)
