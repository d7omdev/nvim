-- Load custom utilities
local Utils = require("custom.utils")

-- ============================================================================
-- Helper Functions
-- ============================================================================

local function opts(desc, extra)
  local default = { noremap = true, silent = true, desc = desc }
  return extra and vim.tbl_extend("force", default, extra) or default
end

-- Mode shortcuts
local N = "n"
local V = "v"
local I = "i"
local T = "t"
local N_V = { N, V }
local N_I = { N, I }

-- ============================================================================
-- Extracted Functions
-- ============================================================================

local function goto_prev_diagnostic()
  require("lspsaga.diagnostic"):goto_prev()
end

local function goto_next_diagnostic()
  require("lspsaga.diagnostic"):goto_next()
end

local function goto_prev_error()
  require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end

local function goto_next_error()
  require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end

local function toggle_quickfix()
  require("quicker").toggle()
end

local function toggle_loclist()
  require("quicker").toggle({ loclist = true })
end

local function markdown_preview()
  if vim.bo.filetype == "markdown" then
    vim.fn.system("xdg-open http://localhost:8989")
  else
    vim.notify("Not a markdown file!", "warn")
  end
end

local function grug_far_next_match()
  local inst = require("grug-far").get_instance()
  if inst then
    inst:goto_next_match({ wrap = true })
    inst:open_location()
  end
end

-- WhichKey group definitions
local wk = require("which-key")
wk.add({
  { "<leader>a", group = "+AI" },
  { "<leader>t", group = "+Themes & Tailwind" },
  { "<leader>G", group = "+Gitsigns" },
  { "<leader>E", group = "+Ecolog" },
})

-- ============================================================================
-- Keymap Definitions
-- ============================================================================

local keymaps = {
  -- ===========================================================================
  -- EDITING & NAVIGATION
  -- ===========================================================================

  -- Duplicate lines/selections
  { N, "<C-A-k>", "yy[P", opts("Duplicate line up") },
  { N, "<C-A-j>", "yy]p", opts("Duplicate line down") },
  { V, "<C-A-k>", "yP", opts("Duplicate selection up") },
  { V, "<C-A-j>", "y]p", opts("Duplicate selection down") },

  -- Visual mode
  { N, "<A-v>", "<C-v>", opts("Block selection") },

  -- Clipboard operations (no yank on delete/change)
  { V, "d", '"ad', opts("Delete without yanking") },
  { N, "c", '"ac', opts("Change without yanking") },
  { V, "c", '"ac', opts("Change without yanking") },
  { N, "x", '"ax', opts("Delete character without yanking") },
  { N_V, "p", '"+p', opts("Paste from system clipboard") },

  -- Quick exit
  { I, "jj", "<Esc>", opts("Exit insert mode") },
  { N_I, "qq", "<cmd>q<CR>", opts("Quick quit") },
  { N, "QQ", Utils.close_all_buffers, opts("Quit all buffers") },

  -- Centered scrolling
  { N, "<C-d>", "<C-d>zz", opts("Scroll down and center") },
  { N, "<C-u>", "<C-u>zz", opts("Scroll up and center") },

  -- Macros
  { N, "Q", "q", opts("Record macro") },
  { N, "q", "<Nop>", opts("Disable default macro key") },

  -- Command mode
  { I, "::", "<Esc>:", opts("Enter command mode in insert mode") },

  -- ===========================================================================
  -- LSP & DIAGNOSTICS
  -- ===========================================================================

  -- LSP Saga
  { N, "<S-r>", "<cmd>Lspsaga hover_doc<CR>", opts("Show hover doc") },
  { N, "<leader>ol", "<cmd>Lspsaga outline<CR>", opts("Show outline") },
  { N, "<C-c>d", "<cmd>Lspsaga peek_definition<CR>", opts("Peek definition") },
  { N, "<C-c>t", "<cmd>Lspsaga peek_type_definition<CR>", opts("Peek type definition") },

  -- Diagnostic navigation
  { N, "[d", goto_prev_diagnostic, opts("Previous diagnostic") },
  { N, "]d", goto_next_diagnostic, opts("Next diagnostic") },
  { N, "[e", goto_prev_error, opts("Previous error") },
  { N, "]e", goto_next_error, opts("Next error") },

  -- ===========================================================================
  -- TREE NAVIGATION (Treewalker)
  -- ===========================================================================

  { N_V, "<S-k>", "<cmd>Treewalker Up<CR>", opts("Treewalker Up") },
  { N_V, "<S-j>", "<cmd>Treewalker Down<CR>", opts("Treewalker Down") },
  { N_V, "<A-l>", "<cmd>Treewalker Right<CR>", opts("Treewalker Right") },
  { N_V, "<A-h>", "<cmd>Treewalker Left<CR>", opts("Treewalker Left") },
  { N, "<A-S-j>", "<cmd>Treewalker SwapDown<CR>", opts("Swap Down") },
  { N, "<A-S-k>", "<cmd>Treewalker SwapUp<CR>", opts("Swap Up") },
  { N, "<A-S-l>", "<cmd>Treewalker SwapRight<CR>", opts("Swap Right") },
  { N, "<A-S-h>", "<cmd>Treewalker SwapLeft<CR>", opts("Swap Left") },

  -- ===========================================================================
  -- BUFFERS & WINDOWS
  -- ===========================================================================

  { N, "<leader>bd", "<cmd>lua Snacks.bufdelete()<CR>", opts("Delete buffer") },
  { N, "<C-p>", "<cmd>BufferLinePick<CR>", opts("Bufferline picker") },
  { N, "<Tab><Tab>", "<cmd>tabnext<CR>", opts("Switch Tab") },

  -- ===========================================================================
  -- TERMINAL
  -- ===========================================================================

  { { N, T }, "<A-t>", "<cmd>Lspsaga term_toggle<CR>", opts("Toggle terminal") },

  -- ===========================================================================
  -- COMMENTS
  -- ===========================================================================

  { N, "<C-/>", "gcc", opts("Comment line", { remap = true }) },
  { N_V, "<C-_>", "gcc", opts("Comment selection", { remap = true }) },
  { I, "<C-_>", "<Esc>:normal gcc<CR>a", opts("Comment line and return to insert mode") },

  -- ===========================================================================
  -- MARKS & RECALL
  -- ===========================================================================

  { N, "<leader>sm", require("recall.snacks").pick, opts("Search Marks") },
  { N, "<S-m>", "<cmd>RecallToggle<CR>", opts("Recall Toggle") },
  { N, "<leader>mr", "<cmd>RecallUnmark<CR>", opts("Recall Unmark") },
  { N, "<leader>ma", "<cmd>RecallMark<CR>", opts("Recall Mark") },
  { N, "]'", "<cmd>RecallNext<CR>", opts("Recall Next") },
  { N, "['", "<cmd>RecallPrevious<CR>", opts("Recall Prev") },
  { N, "mX", "<cmd>RecallClear<CR>", opts("Recall Clear") },

  -- ===========================================================================
  -- SEARCH & REPLACE
  -- ===========================================================================

  { N, "]m", grug_far_next_match, opts("Grug-far next match") },
  {
    N,
    "<leader>sk",
    function()
      Utils.vertical_picker("keymaps")
    end,
    opts("Search keymaps"),
  },

  -- ===========================================================================
  -- QUICKFIX & LOCATION LIST
  -- ===========================================================================

  { N, "<leader>Q", toggle_quickfix, opts("Toggle quickfix") },
  { N, "<leader>L", toggle_loclist, opts("Toggle loclist") },

  -- ===========================================================================
  -- SESSION MANAGEMENT
  -- ===========================================================================

  { N, "<leader>qS", require("persistence").select, opts("Select session") },
  {
    N,
    "<leader>ql",
    function()
      require("persistence").load({ last = true })
    end,
    opts("Load last session"),
  },
  { N, "<leader>qd", require("persistence").stop, opts("Don't save current session") },

  -- ===========================================================================
  -- OBSIDIAN
  -- ===========================================================================

  { N, "<leader>On", ":execute 'ObsidianNew ' . input('Enter a name: ')<CR>", opts("New note") },
  { N, "<leader>Of", require("custom.obsidian").follow_link, opts("Follow link") },
  { N, "<leader>Or", ":execute 'ObsidianRename ' . input('Enter new name: ')<CR>", opts("Rename note") },

  -- ===========================================================================
  -- TAILWIND TOOLS
  -- ===========================================================================

  { N, "<leader>tts", "<cmd>TailwindSort<CR>", opts("Tailwind Sort") },
  { N, "<leader>ttS", "<cmd>TailwindSortSelection<CR>", opts("Tailwind Sort Selection") },
  { N, "<leader>ttc", "<cmd>TailwindConcealToggle<CR>", opts("Tailwind Conceal Toggle") },

  -- ===========================================================================
  -- OVERSEER (Task Runner)
  -- ===========================================================================

  { N, "<leader>R", "<cmd>OverseerRunC<CR>", opts("Overseer Run") },
  { N, "<leader>Rt", "<cmd>OverseerToggle<CR>", opts("Overseer Toggle") },

  -- ===========================================================================
  -- UTILITIES
  -- ===========================================================================

  {
    N,
    "z=",
    function()
      Utils.select("spelling")
    end,
    opts("Spelling suggestions"),
  },
  { N, "<leader>gp", Utils.open_github_repo, opts("Open Github repo") },
  { N, "<leader>Mp", markdown_preview, opts("Markdown preview") },
  { V, "<leader>cW", Utils.wrap_with_tag, opts("Wrap selection with tag") },

  -- ===========================================================================
  -- AI TOOLS
  -- ===========================================================================

  { V, "<leader>i", require("custom.ai-inline").edit_selection, opts("Claude inline edit") },
}

-- ============================================================================
-- Apply Keymaps
-- ============================================================================

for _, keymap in ipairs(keymaps) do
  local mode, lhs, rhs, options = keymap[1], keymap[2], keymap[3], keymap[4]
  vim.keymap.set(mode, lhs, rhs, options)
end

-- ============================================================================
-- User Commands
-- ============================================================================

vim.api.nvim_create_user_command("ClaudeInlineSelectModel", function()
  require("custom.ai-inline").select_model()
end, { desc = "Select Claude/Codex model for inline edits" })
