return function()
  require("tiny-inline-diagnostic").setup({
    preset = "simple",
    options = {
      show_source = true,
      use_icons_from_diagnostic = true,
      show_all_diags_on_cursorline = true,
    },
  })
end

