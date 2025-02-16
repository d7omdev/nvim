-- Helper function for keymap options
local function opts(desc, extra)
  local default = { noremap = true, silent = true, desc = desc }
  return extra and vim.tbl_extend("force", default, extra) or default
end

local map = vim.keymap.set

-- Duplicate lines or selections
map("n", "<C-A-k>", "yy[P", opts("Duplicate line up"))
map("n", "<C-A-j>", "yy]p", opts("Duplicate line down"))
map("v", "<C-A-k>", "yP", opts("Duplicate selection up"))
map("v", "<C-A-j>", "y]p", opts("Duplicate selection down"))

-- Block selection
map("n", "<A-q>", "<C-v>", { noremap = true, silent = true })

-- Remap delete without copying
-- map("n", "d", '"ad', opts())
map("v", "d", '"ad', opts())

map({ "n", "v" }, "p", '"+p', opts("Paste from 0 register"))

-- Remap change without copying
map("n", "c", '"ac', opts())
map("v", "c", '"ac', opts())

-- Remap x (delete character) without copying
map("n", "x", '"ax', opts())

-- Exit modes
map("i", "jj", "<Esc>", opts("Exit insert mode"))
map({ "n", "i" }, "qq", "<cmd>q<CR>", opts("Quick quit"))
map("n", "QQ", "<cmd>bufdo bd<CR>", opts("Quit all buffers"))

-- Delete without copying to register
map("v", "<Del>", '"_d', opts("Delete without yanking"))
-- Plugins Keymaps
-- DBUI
-- map("n", "<leader>DB", ":tabnew | DBUI<CR>", opts("Open DBUI"))

-- Lspsaga
map("n", "<S-r>", "<cmd>Lspsaga hover_doc<CR>", opts("Show hover doc"))
map("n", "<leader>ol", "<cmd>Lspsaga outline<CR>", opts("Show outline"))
map("n", "<C-c>d", "<cmd>Lspsaga peek_definition<CR>", opts("Peek definition"))
map("n", "<C-c>t", "<cmd>Lspsaga peek_type_definition<CR>", opts("Peek type definition"))
map("n", "[d", function()
  require("lspsaga.diagnostic"):goto_prev()
end, opts("Previous diagnostic"))
map("n", "]d", function()
  require("lspsaga.diagnostic"):goto_next()
end, opts("Next diagnostic"))
map("n", "[e", function()
  require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, opts("Previous error"))
map("n", "]e", function()
  require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end, opts("Next error"))

-- Obsidian
map("n", "<leader>O", "", opts("+Obsidian"))
map("n", "<leader>On", ":execute 'ObsidianNew ' . input('Enter a name: ')<CR>", opts("New note"))
map("n", "<leader>Os", ":ObsidianQuickSwitch<CR>", opts("Quick switch"))
map("n", "<leader>Of", ":lua require('custom.obsidian').follow_link()<CR>", opts("Follow link"))
map("n", "<leader>Ob", ":ObsidianBacklinks<CR>", opts("Backlinks"))
map("n", "<leader>Od", ":ObsidianDailies<CR>", opts("Dailies"))
map("n", "<leader>Ot", ":ObsidianTemplate<CR>", opts("Insert template"))
map("n", "<leader>sO", "<cmd>ObsidianSearch<CR>", opts("Search notes"))
map("n", "<leader>Or", ":execute 'ObsidianRename ' . input('Enter new name: ')<CR>", opts("Rename note"))
map("n", "<leader>Oc", ":ObsidianToggleCheckbox<CR>", opts("Toggle checkbox"))
map("n", "<leader>OT", "<cmd>ObsidianTags<CR>", opts("Search tags"))

-- Sessions
map("n", "<leader>qS", function()
  require("persistence").select()
end, opts("Select session"))
map("n", "<leader>ql", function()
  require("persistence").load({ last = true })
end, opts("Load last session"))
map("n", "<leader>qd", function()
  require("persistence").stop()
end, opts("Don't save current session"))

-- Tailwind Tools
map("n", "<leader>tt", "", opts("+Tailwind"))
map("n", "<leader>tts", "<cmd>TailwindSort<CR>", opts("Tailwind Sort"))
map("n", "<leader>ttS", "<cmd>TailwindSortSelection<CR>", opts("Tailwind Sort Selection"))
map("n", "<leader>ttc", "<cmd>TailwindConcealToggle<CR>", opts("Tailwind Conceal Toggle"))

-- Buffers
map("n", "]b", require("custom.buffers").next_buffer_in_tab, opts("Next buffer in tab"))
map("n", "[b", require("custom.buffers").prev_buffer_in_tab, opts("Previous buffer in tab"))
local tabufline = require("nvchad.tabufline")
map("n", "[B", function()
  tabufline.move_buf(-1)
end, opts("Move buffer left"))
map("n", "]B", function()
  tabufline.move_buf(1)
end, opts("Move buffer right"))
map("n", "<leader>bd", "<cmd>lua Snacks.bufdelete()<CR>", opts("Delete buffer"))

-- Treewalker
map({ "n", "v" }, "<S-k>", "<cmd>Treewalker Up<CR>", opts("Treewalker Up"))
map({ "n", "v" }, "<S-j>", "<cmd>Treewalker Down<CR>", opts("Treewalker Down"))
map({ "n", "v" }, "<A-l>", "<cmd>Treewalker Right<CR>", opts("Treewalker Right"))
map({ "n", "v" }, "<A-h>", "<cmd>Treewalker Left<CR>", opts("Treewalker Left"))
map("n", "<A-S-j>", "<cmd>Treewalker SwapDown<CR>", opts("Swap Down"))
map("n", "<A-S-k>", "<cmd>Treewalker SwapUp<CR>", opts("Swap Up"))
map("n", "<A-S-l>", "<cmd>Treewalker SwapRight<CR>", opts("Swap Right"))
map("n", "<A-S-h>", "<cmd>Treewalker SwapLeft<CR>", opts("Swap Left"))

-- Tabs
map("n", "<Tab><Tab>", "<cmd>tabnext<CR>", opts("Switch Tab"))

-- Miscellaneous
map("i", "::", "<Esc>:", opts("Enter command mode in insert mode"))
map("n", "<leader>Q", function()
  require("quicker").toggle()
end, opts("Toggle quickfix"))
map("n", "<leader>L", function()
  require("quicker").toggle({ loclist = true })
end, opts("Toggle loclist"))

require("quicker").setup({
  keys = {
    {
      ">",
      function()
        require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
      end,
      opts("Expand quickfix context"),
    },
    {
      "<",
      function()
        require("quicker").collapse()
      end,
      opts("Collapse quickfix context"),
    },
   },
})

-- Use dressing (or mini.pick) for spelling suggestions.
map("n", "z=", "<cmd>Pick spellsuggest<CR>", { desc = "Spelling suggestions" })

map("n", "<C-p>", "<cmd>Pick files<CR>", { desc = "Mini files picker" })

map("n", "<leader>gp", function()
  require("custom.utils").open_github_repo()
end, { desc = "Open Github repo" })

map({ "n", "t" }, "<A-t>", "<cmd>Lspsaga term_toggle<CR>")
