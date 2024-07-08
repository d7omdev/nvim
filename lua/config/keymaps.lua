-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Remove default keymaps
vim.keymap.del("n", "<leader>gg")

map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Lazygit" })
-- Remove the old keymap

-- Exit insert mode with 'jj' in insert mode
map("i", "jj", "<Esc>", { noremap = true, silent = true })

-- search and replace using regex
map("n", "zz", ":'<,'>s//<Left>", { noremap = true, silent = true })

-- Exit with 'qq' in normal mode
map("n", "qq", ":q<CR>", { noremap = true, silent = true })

-- Delete without copying to register in visual mode
map("v", "<Del>", '"_d', { noremap = true, silent = true })

-- Makdown preview
map("n", "<leader>mb", ":MarkdownPreview<CR>", { noremap = true, silent = true })

-- DBui
map("n", "<leader>uD", ":tabnew | DBUI<CR>", { noremap = true, silent = true })

-- Lspsaga keymaps
map("n", "<leader>r", "<cmd>Lspsaga hover_doc<CR>", { desc = "show hover doc" })
map("n", "<leader>ol", "<cmd>Lspsaga outline<CR>", { desc = "show outline" })
-- map("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "code action" })
map("n", "<C-c>d", "<cmd>Lspsaga peek_definition<CR>", { desc = "peek definition" })

-- Auto save toggle
-- vim.api.nvim_set_keymap("n", "<leader>AST", ":ASToggle<CR>", {})
map("n", "<leader>AST", ":ASToggle<CR>", { noremap = true, silent = true })

-- Cheat.sh
map("n", "<leader>ch", "<cmd>Cheat<CR>", { noremap = true, silent = true, desc = "Cheat Sheet" })

-- LSP saga
map("n", "]D", "<cmd>Lspsaga diagnostic_jump_next<CR>", { noremap = true, silent = true, desc = "Next diagnostic" })
map("n", "[D", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { noremap = true, silent = true, desc = "Previous diagnostic" })
map("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { noremap = true, silent = true, desc = "Code action" })
-- map Lspsaga peek_definition
-- map("n", "<C-c>d", "<cmd>Lspsaga peek_definition<CR>", { noremap = true, silent = true, desc = "Peek definition" })
-- now Lspsaga peek_type_definition
map(
  "n",
  "<C-c>t",
  "<cmd>Lspsaga peek_type_definition<CR>",
  { noremap = true, silent = true, desc = "Peek type definition" }
)
