return {
  {
    "aserowy/tmux.nvim",
    config = function()
      return require("tmux").setup()
    end,
  },
  {
    "lambdalisue/vim-suda",
    config = function()
      vim.g.suda_smart_edit = 1
      -- Expand 'ss' into 'SudaWrite' in the command line
      vim.cmd([[cab ss SudaWrite]])
    end,
  },

  -- Menu
  { "nvchad/volt", lazy = true },
  { "nvchad/minty", lazy = true },
  {
    "nvchad/menu",

    lazy = true,
    config = function()
      require("menu").open({
        {
          name = "Format Buffer",
          cmd = function()
            local ok, conform = pcall(require, "conform")

            if ok then
              conform.format({ lsp_fallback = true })
            else
              vim.lsp.buf.format()
            end
          end,
          rtxt = "<leader>cf",
        },
      })
    end,
  },
  vim.keymap.set("n", "<RightMouse>", function()
    vim.cmd.exec('"normal! \\<RightMouse>"')

    local options = vim.bo.ft == "NvimTree" and "nvimtree" or "default"
    require("menu").open(options, { mouse = true })
  end, {}),
}
