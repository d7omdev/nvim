return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
  -- Disabling these plugins if nvchad ui is used
  { "nvim-lualine/lualine.nvim", enabled = false },
  { "nvim-mini/mini.icons", enabled = false },
  -- markview.nvim covers markdown rendering; drop redundant render-markdown
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },
}
