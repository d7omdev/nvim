return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Open file history" },
    { "<leader>gbr", "<cmd>DiffviewOpen origin/HEAD...HEAD --imply-local<cr>", desc = "Review branch changes" },
    { "<leader>gc", "<cmd>DiffviewClose<CR>", desc = "close view" },
  },
  config = function()
    require("diffview").setup({
      enhanced_diff_hl = true,
      git_cmd = { "git" },
      use_icons = true,
      merge_tool = {
        layout = "diff4_mixed",
        disable_diagnostics = true,
        winbar_info = true,
      },
      view = {
        merge_tool = {
          layout = "diff4_mixed",
        },
      },
      hooks = {
        view_opened = function(view)
          -- Store current colorscheme
          vim.g.old_colorscheme = vim.g.colors_name
          -- Switch to github theme
        end,
        view_closed = function()
          -- Restore previous colorscheme
          if vim.g.old_colorscheme then
            vim.cmd("colorscheme " .. vim.g.old_colorscheme)
          end
        end,
      },
    })
  end,
}
