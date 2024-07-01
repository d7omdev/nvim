return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  config = function()
    vim.opt.updatetime = 100
    vim.diagnostic.config({ virtual_text = false })
    vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#f76464" })
    vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#f7bf64" })
    vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#64bcf7" })
    -- vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#64f79d" })
    require("tiny-inline-diagnostic").setup({
      blend = {
        factor = 0.2,
      },
      hi = {
        error = "DiagnosticError",
        warn = "DiagnosticWarn",
        info = "DiagnosticInfo",
        hint = "DiagnosticHint",
        arrow = "NonText",
        background = "CursorLine", -- Can be a highlight or a hexadecimal color (#RRGGBB)
        mixing_color = "#2f3245", -- Can be None or a hexadecimal color (#RRGGBB). Used to blend the background color with the diagnostic background color with another color.
      },
    })
  end,
}
