return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    terminal = {
      win = {
        wo = {
          winbar = "",
        },
      },
    },
    profiler = { enabled = true },
    picker = {
      layout = {
        preview = true,
        layout = {
          backdrop = false,
          row = 1,
          width = 0.7,
          min_width = 80,
          height = 0.8,
          border = "none",
          box = "vertical",
          { win = "input", height = 1, border = "double", title = "{title} {live} {flags}", title_pos = "center" },
          { win = "list", height = 0.4 },
          {
            win = "preview",
            title = "{preview:Preview}",
            border = "single",
            title_pos = "center",
          },
        },
      },
    },
    indent = {
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
    },
    bigfile = { enabled = true },
    dashboard = { ---@class snacks.dashboard.Config
      ---@field sections snacks.dashboard.Section
      ---@field formats table<string, snacks.dashboard.Text|fun(item:snacks.dashboard.Item, ctx:snacks.dashboard.Format.ctx):snacks.dashboard.Text>

      width = 60,
      row = nil, -- dashboard position. nil for center
      col = nil, -- dashboard position. nil for center
      pane_gap = 4, -- empty columns between vertical panes
      autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", -- autokey sequence
      -- These settings are used by some built-in sections
      preset = {
        -- Defaults to a picker that supports `fzf-lua`, `telescope.nvim` and `mini.pick`
        ---@type fun(cmd:string, opts:table)|nil
        pick = nil,
        -- Used by the `keys` section to show keymaps.
        -- Set your curstom keymaps here.
        -- When using a function, the `items` argument are the default keymaps.
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          -- { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = "", key = "x", desc = "Lazy Extras", action = "<cmd>LazyExtras<cr>" },
          { icon = " ", key = "m", desc = "Marks", action = ":lua Snacks.dashboard.pick('marks')" },
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
        -- Used by the `header` section
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
          -- cmd = "colorscript -e square",
          cmd = "fastfetch --logo none | rg --colors=match:fg:cyan '|||||󰝚|'",
          height = 6,
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
    },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      notification = {
        wo = { wrap = false }, -- Wrap notifications
      },
    },
  },
  keys = {
    {
      "<leader>.",
      function()
        Snacks.scratch()
      end,
      desc = "Toggle Scratch Buffer",
    },
    {
      "<leader>S",
      function()
        Snacks.scratch.select()
      end,
      desc = "Select Scratch Buffer",
    },
    {
      "<leader>n",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },
    {
      "<leader>bd",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete Buffer",
    },
    {
      "<leader>cR",
      function()
        Snacks.rename.rename_file()
      end,
      desc = "Rename File",
    },
    {
      "<leader>gB",
      function()
        Snacks.gitbrowse()
      end,
      desc = "Git Browse",
    },
    {
      "<leader>gb",
      function()
        Snacks.git.blame_line()
      end,
      desc = "Git Blame Line",
    },
    {
      "<leader>gf",
      function()
        Snacks.lazygit.log_file()
      end,
      desc = "Lazygit Current File History",
    },
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "<leader>gl",
      function()
        Snacks.lazygit.log()
      end,
      desc = "Lazygit Log (cwd)",
    },
    {
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Dismiss All Notifications",
    },
    {
      "<c-/>",
      function()
        Snacks.terminal()
      end,
      desc = "Toggle Terminal",
    },
    {
      "<c-_>",
      function()
        Snacks.terminal()
      end,
      desc = "which_key_ignore",
    },
    {
      "]]",
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = "Next Reference",
      mode = { "n", "t" },
    },
    {
      "[[",
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = "Prev Reference",
      mode = { "n", "t" },
    },
    {
      "<leader>N",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
