-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Remove default keymaps
vim.keymap.del("n", "<leader>gg")

map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<S-A-k>", "yykP", { noremap = true, silent = true, desc = "Duplicate line up" })
map("n", "<S-A-j>", "yyp", { noremap = true, silent = true, desc = "Duplicate line down" })
-- map("v", "<A-Up>", ":<C-u>move '<-2<CR>gv-gv", { desc = "Move selection up" })
-- map("v", "<A-Down>", ":<C-u>move '>+1<CR>gv-gv", { desc = "Move selection down" })

map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Lazygit" })
-- Remove the old keymap

-- Exit insert mode with 'jj' in insert mode
map("i", "jj", "<Esc>", { noremap = true, silent = true })

-- Exit with 'qq' in normal mode
map("n", "qq", ":q<CR>", { noremap = true, silent = true })

-- Delete without copying to register in visual mode
map("v", "<Del>", '"_d', { noremap = true, silent = true })

-- Makdown preview
map("n", "<leader>mp", ":MarkdownPreview<CR>", { noremap = true, silent = true })

-- DBui
map("n", "<leader>uD", ":tabnew | DBUI<CR>", { noremap = true, silent = true })

-- Lspsaga keymaps
map("n", "<S-r>", "<cmd>Lspsaga hover_doc<CR>", { desc = "show hover doc" })
map("n", "<leader>ol", "<cmd>Lspsaga outline<CR>", { desc = "show outline" })
map("n", "<C-a>", "<cmd>Lspsaga code_action<CR>", { desc = "code action" })
map("n", "<C-c>d", "<cmd>Lspsaga peek_definition<CR>", { desc = "peek definition" })
map("n", "<C-c>t", "<cmd>Lspsaga peek_type_definition<CR>", { desc = "peek type definition" })

-- Auto save toggle
map("n", "<leader>AST", ":ASToggle<CR>", { noremap = true, silent = true })

-- Cheat.sh
map("n", "<leader>ch", "<cmd>Cheat<CR>", { noremap = true, silent = true, desc = "Cheat Sheet" })

-- LSP saga
map("n", "]D", "<cmd>Lspsaga diagnostic_jump_next<CR>", { noremap = true, silent = true, desc = "Next diagnostic" })
map("n", "[D", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { noremap = true, silent = true, desc = "Previous diagnostic" })

-- Obsidian

map("n", "<leader>O", "", { desc = "+Obsidian" })
map(
  "n",
  "<leader>On",
  ":execute 'ObsidianNew ' . input('Enter a name: ')<CR>",
  { noremap = true, silent = true, desc = "New note" }
)
map("n", "<leader>Os", ":ObsidianQuickSwitch<CR>", { noremap = true, silent = true, desc = "Quick switch" })
map(
  "n",
  "<leader>Of",
  ":lua local user_input = vim.fn.input('Enter v for vsplit, h for hsplit or leave empty: ') if user_input == 'v' then vim.cmd('ObsidianFollowLink vsplit') elseif user_input == 'h' then vim.cmd('ObsidianFollowLink hsplit') else vim.cmd('ObsidianFollowLink') end<CR>",
  { noremap = true, silent = true, desc = "Follow link" }
)
map("n", "<leader>Ob", ":ObsidianBacklinks<CR>", { noremap = true, silent = true, desc = "Backlinks" })
map("n", "<leader>Od", ":ObsidianDailies<CR>", { noremap = true, silent = true, desc = "Dailies" })
map(
  "n",
  "<leader>Ot",
  ":execute '<cmd>ObsidianTemplate<CR>",
  { noremap = true, silent = true, desc = "Insert template" }
)
map("n", "<leader>sO", "<cmd>ObsidianSearch<CR>", { noremap = true, silent = true, desc = "Obsidian search" })
map(
  "n",
  "<leader>Or",
  ":execute 'ObsidianRename ' . input('Enter new name: ')<CR>",
  { noremap = true, silent = true, desc = "Rename note" }
)
map("n", "<leader>Oc", ":ObsidianToggleCheckbox<CR>", { noremap = true, silent = true, desc = "Toggle checkbox" })
map("n", "<leader>OT", "<cmd>ObsidianTags<CR>", { desc = "Search tags" })

-- Sessions
map("n", "<leader>qS", function()
  require("persistence").select()
end, { desc = "Select session" })

map("n", "<leader>ql", function()
  require("persistence").load({ last = true })
end, { desc = "Load last session" })

map("n", "<leader>qd", function()
  require("persistence").stop()
end, { desc = "Don't save current session" })

-- Projects
map("n", "<leaderP", "", { desc = "+Projects" })
map("n", "<leader>Pd", "<cmd>Telescope neovim-project discover<CR>", { desc = "Discover projects" })
map("n", "<leader>PhDiscover projects", "<cmd>Telescope neovim-project history<CR>", { desc = "Projects history" })

map("n", "<leader>gh", "", { desc = "+Gitsigns" })
