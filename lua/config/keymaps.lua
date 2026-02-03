-- Load custom utilities
local Utils = require("custom.utils")

-- For Hyprland: Add to hyprland.conf: input { kb_options = caps:escape }
-- Helper function for keymap options
local function opts(desc, extra)
  local default = { noremap = true, silent = true, desc = desc }
  return extra and vim.tbl_extend("force", default, extra) or default
end

local N = "n"
local V = "v"
local I = "i"
local T = "t"
local N_V = { N, V }
local N_I = { N, I }

-- WhichKey group definitions
local wk = require("which-key")
wk.add({
  { "<leader>a", group = "+AI" },
  { "<leader>t", group = "+Themes & Tailwind" },
  { "<leader>G", group = "+Gitsigns" },
  { "<leader>E", group = "+Ecolog" },
})

-- Keymap definitions
local keymaps = {
  -- ===================
  -- General Keymaps
  -- ===================
  -- { I, "<Tab>", "<C-V><Tab>", opts("Insert tab") },
  { N, "<C-A-k>", "yy[P", opts("Duplicate line up") },
  { N, "<C-A-j>", "yy]p", opts("Duplicate line down") },
  { V, "<C-A-k>", "yP", opts("Duplicate selection up") },
  { V, "<C-A-j>", "y]p", opts("Duplicate selection down") },

  { N, "<A-v>", "<C-v>", opts("Block selection") },

  { V, "d", '"ad', opts("Delete without yanking") },
  { N_V, "p", '"+p', opts("Paste from system clipboard") },
  { N, "c", '"ac', opts("Change without yanking") },
  { V, "c", '"ac', opts("Change without yanking") },
  { N, "x", '"ax', opts("Delete character without yanking") },

  { I, "jj", "<Esc>", opts("Exit insert mode") },
  { N_I, "qq", "<cmd>q<CR>", opts("Quick quit") },
  {
    N,
    "QQ",
    function()
      Utils.close_all_buffers()
    end,
    opts("Quit all buffers"),
  },

  { N, "<C-d>", "<C-d>zz", opts("Scroll down and center") },
  { N, "<C-u>", "<C-u>zz", opts("Scroll up and center") },

  -- ===================
  -- Plugin Keymaps
  -- ===================
  -- Lspsaga
  { N, "<S-r>", "<cmd>Lspsaga hover_doc<CR>", opts("Show hover doc") },
  { N, "<leader>ol", "<cmd>Lspsaga outline<CR>", opts("Show outline") },
  { N, "<C-c>d", "<cmd>Lspsaga peek_definition<CR>", opts("Peek definition") },
  { N, "<C-c>t", "<cmd>Lspsaga peek_type_definition<CR>", opts("Peek type definition") },
  {
    N,
    "[d",
    function()
      require("lspsaga.diagnostic"):goto_prev()
    end,
    opts("Previous diagnostic"),
  },
  {
    N,
    "]d",
    function()
      require("lspsaga.diagnostic"):goto_next()
    end,
    opts("Next diagnostic"),
  },
  {
    N,
    "[e",
    function()
      require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end,
    opts("Previous error"),
  },
  {
    N,
    "]e",
    function()
      require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
    end,
    opts("Next error"),
  },

  -- Obsidian (keymaps defined in plugin config for lazy loading)
  {
    N,
    "<leader>On",
    ":execute 'ObsidianNew ' . input('Enter a name: ')<CR>",
    opts("New note"),
  },
  {
    N,
    "<leader>Of",
    function()
      require("custom.obsidian").follow_link()
    end,
    opts("Follow link"),
  },
  {
    N,
    "<leader>Or",
    ":execute 'ObsidianRename ' . input('Enter new name: ')<CR>",
    opts("Rename note"),
  },

  -- Sessions
  {
    N,
    "<leader>qS",
    function()
      require("persistence").select()
    end,
    opts("Select session"),
  },
  {
    N,
    "<leader>ql",
    function()
      require("persistence").load({ last = true })
    end,
    opts("Load last session"),
  },
  {
    N,
    "<leader>qd",
    function()
      require("persistence").stop()
    end,
    opts("Don't save current session"),
  },

  -- Tailwind Tools
  { N, "<leader>tts", "<cmd>TailwindSort<CR>", opts("Tailwind Sort") },
  { N, "<leader>ttS", "<cmd>TailwindSortSelection<CR>", opts("Tailwind Sort Selection") },
  { N, "<leader>ttc", "<cmd>TailwindConcealToggle<CR>", opts("Tailwind Conceal Toggle") },

  -- Buffers
  { N, "<leader>bd", "<cmd>lua Snacks.bufdelete()<CR>", opts("Delete buffer") },

  -- Treewalker
  { N_V, "<S-k>", "<cmd>Treewalker Up<CR>", opts("Treewalker Up") },
  { N_V, "<S-j>", "<cmd>Treewalker Down<CR>", opts("Treewalker Down") },
  { N_V, "<A-l>", "<cmd>Treewalker Right<CR>", opts("Treewalker Right") },
  { N_V, "<A-h>", "<cmd>Treewalker Left<CR>", opts("Treewalker Left") },
  { N, "<A-S-j>", "<cmd>Treewalker SwapDown<CR>", opts("Swap Down") },
  { N, "<A-S-k>", "<cmd>Treewalker SwapUp<CR>", opts("Swap Up") },
  { N, "<A-S-l>", "<cmd>Treewalker SwapRight<CR>", opts("Swap Right") },
  { N, "<A-S-h>", "<cmd>Treewalker SwapLeft<CR>", opts("Swap Left") },

  -- Tabs
  { N, "<Tab><Tab>", "<cmd>tabnext<CR>", opts("Switch Tab") },

  -- Miscellaneous
  { I, "::", "<Esc>:", opts("Enter command mode in insert mode") },
  {
    N,
    "<leader>Q",
    function()
      require("quicker").toggle()
    end,
    opts("Toggle quickfix"),
  },
  {
    N,
    "<leader>L",
    function()
      require("quicker").toggle({ loclist = true })
    end,
    opts("Toggle loclist"),
  },
  {
    N,
    "z=",
    function()
      Utils.select("spelling")
    end,
    opts("Spelling suggestions"),
  },
  { N, "<C-p>", "<cmd>BufferLinePick<CR>", opts("Bufferline picke") },
  {
    N,
    "<leader>gp",
    function()
      Utils.open_github_repo()
    end,
    opts("Open Github repo"),
  },
  { { N, T }, "<A-t>", "<cmd>Lspsaga term_toggle<CR>", opts("Toggle terminal") },
  {
    N,
    "<leader>Mp",
    function()
      if vim.bo.filetype == "markdown" then
        vim.fn.system("xdg-open http://localhost:8989")
      else
        vim.notify("Not a markdown file!", "warn")
      end
    end,
    opts("Markdown preview"),
  },
  {
    V,
    "<leader>cW",
    function()
      Utils.wrap_with_tag()
    end,
    opts("Wrap selection with tag"),
  },
  {
    N,
    "<leader>sk",
    function()
      Utils.vertical_picker("keymaps")
    end,
    opts("Search keymaps"),
  },
  {
    N,
    "<leader>R",
    "<cmd>OverseerRunC<CR>",
    opts("Overseer Run"),
  },
  {
    N,
    "<leader>Rt",
    "<cmd>OverseerToggle<CR>",
    opts("Overseer Toggle"),
  },
  {
    N,
    "<C-/>",
    "gcc",
    opts("Comment line", { remap = true }),
  },
  {
    N,
    "Q",
    "q",
    opts("Record macro"),
  },
  {
    N,
    "q",
    "<Nop>",
    opts("Disable default macro key"),
  },
  {
    N_V,
    "<C-_>",
    "gcc",
    opts("Comment selection", { remap = true }),
  },
  {
    I,
    "<C-_>",
    "<Esc>:normal gcc<CR>a",
    opts("Comment line and return to insert mode"),
  },
  {
    N,
    "<leader>sm",
    require("recall.snacks").pick,
    opts("Search Marks"),
  },
  {
    N,
    "<S-m>",
    "<cmd>RecallToggle<CR>",
    opts("Recall Toggle"),
  },
  {
    N,
    "<leader>mr",
    "<cmd>RecallUnmark<CR>",
    opts("Recall Unmark"),
  },
  {
    N,
    "<leader>ma",
    "<cmd>RecallMark<CR>",
    opts("Recall Mark"),
  },
  {
    N,
    "]'",
    "<cmd>RecallNext<CR>",
    opts("Recall Next"),
  },
  {
    N,
    "['",
    "<cmd>RecallPrevious<CR>",
    opts("Recall Prev"),
  },
  {
    N,
    "mX",
    "<cmd>RecallClear<CR>",
    opts("Recall Clear"),
  },
  {
    N,
    "]m",
    function()
      local inst = require("grug-far").get_instance()
      if inst then
        inst:goto_next_match({ wrap = true })
        inst:open_location()
      end
    end,
    opts("Grug-far next match"),
  },

  -- Claude inline edit
  {
    V,
    "<leader>i",
    function()
      require("custom.claude-inline").edit_selection()
    end,
    opts("Claude inline edit"),
  },
}

-- Apply all keymaps
for _, keymap in ipairs(keymaps) do
  local mode = keymap[1]
  local lhs = keymap[2]
  local rhs = keymap[3]
  local options = keymap[4]
  vim.keymap.set(mode, lhs, rhs, options)
end
