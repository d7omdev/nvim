-- Main configuration table
local opts = {}

-- ===============================
-- Terminal Configuration
-- ===============================
opts.terminal = {
  win = {
    wo = {
      winbar = "",
    },
  },
}

-- ===============================
-- Image Configuration
-- ===============================
---@class snacks.image.Config
opts.image = { enabled = true, doc = {
  inline = false,
} }

-- ===============================
-- Profiler Configuration
-- ===============================
opts.profiler = { enabled = true }

-- ===============================
-- Picker Configuration
-- ===============================
---@class snacks.picker.Config
opts.picker = {
  layout = {
    layout = {
      box = "horizontal",
      border = "none",
      width = 0.8,
      min_width = 120,
      height = 0.8,
      {
        box = "vertical",
        border = "single",
        title = "{title} {live} {flags}",
        { win = "input", height = 1, border = "single" },
        { win = "list", border = "none" },
      },
      { win = "preview", title = "{preview}", border = "single", width = 0.6 },
    },
  },
}

-- ===============================
-- Indent Configuration
-- ===============================
---@class snacks.indent.Config
opts.indent = {
  enabled = true,
  chunk = {
    enabled = true,
    -- only show chunk scopes in the current window
    only_current = false,
    hl = "SnacksIndentChunk", ---@type string|string[] hl group for chunk scopes
    char = {
      corner_top = "┌",
      corner_bottom = "└",
      -- corner_top = "╭",
      -- corner_bottom = "╰",
      horizontal = "─",
      vertical = "│",
      arrow = "─",
    },
  },
}

-- ===============================
-- Bigfile Configuration
-- ===============================
---@class snacks.bigfile.Config
opts.bigfile = { enabled = true }

-- ===============================
-- Dashboard Configuration
-- ===============================
---@class snacks.dashboard.Config
opts.dashboard = {
  width = 60,
  row = nil, -- dashboard position. nil for center
  col = nil, -- dashboard position. nil for center
  pane_gap = 4, -- empty columns between vertical panes
  autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", -- autokey sequence

  -- Preset settings used by some built-in sections
  preset = {
    pick = nil,
    keys = {
      { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
      { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
      { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
      { icon = "", key = "x", desc = "Lazy Extras", action = "<cmd>LazyExtras<cr>" },
      -- { icon = " ", key = "m", desc = "Marks", action = ":lua Snacks.dashboard.pick('marks')" },
      {
        icon = " ",
        key = "c",
        desc = "Config",
        action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
      },
      { icon = " ", key = "s", desc = "Restore Session", section = "session" },
      { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
      { icon = " ", key = "q", desc = "Quit", action = ":qa" },
    },
    header = [[
 ██████╗ ███████╗ ██████╗ ███╗   ███╗
 ██╔══██╗╚════██║██╔═══██╗████╗ ████║
 ██║  ██║    ██╔╝██║   ██║██╔████╔██║
 ██║  ██║   ██╔╝ ██║   ██║██║╚██╔╝██║
 ██████╔╝   ██║  ╚██████╔╝██║ ╚═╝ ██║
 ╚═════╝    ╚═╝   ╚═════╝ ╚═╝     ╚═╝
 [d7om.dev]
    ]],
  },
  sections = {
    { section = "header" },
    {
      pane = 2,
      section = "terminal",
      -- cmd = "fastfetch --logo none | rg --colors=match:fg:cyan '|||||󰝚|'",
      cmd = "pipes.sh -t 1",
      height = 8,
      padding = 2,
    },
    { section = "keys", gap = 1, padding = 1 },
    { pane = 2, icon = "", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
    {
      pane = 2,
      icon = " ",
      title = "Git Status",
      section = "terminal",
      enabled = vim.fn.isdirectory(".git") == 1,
      cmd = "hub status --short --branch --renames",
      height = 5,
      padding = 1,
      ttl = 5 * 60,
      indent = 3,
    },
    { section = "startup" },
  },
}

-- ===============================
-- Notifier Configuration
-- ===============================
opts.notifier = {
  enabled = true,
  timeout = 3000,
}

-- ===============================
-- Quickfile Configuration
-- ===============================
opts.quickfile = { enabled = true }

-- ===============================
-- Statuscolumn Configuration
-- ===============================
opts.statuscolumn = { enabled = true }

-- ===============================
-- Words Configuration
-- ===============================
opts.words = { enabled = true }

-- ===============================
-- Styles Configuration
-- ===============================
opts.styles = {
  notification = {
    border = "single",
    wo = { wrap = false }, -- Wrap notifications
  },
  notification_history = {
    border = "single",
  },
  input = {
    backdrop = false,
    position = "float",
    border = "single",
    height = 1,
    width = 40,
    relative = "cursor",
    row = -3,
    col = 1,
    b = {
      completion = false,
    },
  },
}

-- scroll conf

-- ===============================
-- Scroll Configuration
-- ===============================
opts.scroll = {
  enabled = false,
}

-- ===============================
-- Keybindings Configuration
-- ===============================
local keys = {
  -- {
  --   "<leader>gB",
  --   function()
  --     Snacks.gitbrowse()
  --   end,
  --   desc = "Git Browse",
  -- },
  -- {
  --   "<leader>gg",
  --   function()
  --     Snacks.lazygit()
  --   end,
  --   desc = "Lazygit",
  -- },
}

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = opts,
  keys = keys,
}
