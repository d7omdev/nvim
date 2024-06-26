-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Select the whole file with Ctrl + a in normal mode
map("n", "<C-a>", "ggVG", { noremap = true, silent = true })

-- Exit insert mode with 'jj' in insert mode
map("i", "jj", "<Esc>", { noremap = true, silent = true })

map("n", "zz", ":'<,'>s//<Left>", { noremap = true, silent = true })
