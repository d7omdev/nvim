return function()
  require("modes").setup({
    line_opacity = 0.2,
    set_cursorline = false,
    set_number = false,
    ignore = { "NvimTree", "TelescopePrompt", "dashboard", "minifiles" },
  })
end

