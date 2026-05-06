---@type vim.lsp.Config
return {
  -- GDScript (Godot) configuration
  cmd = { "nc", "localhost", "6005" },
  filetypes = { "gd", "gdscript", "gdscript3" },
  root_markers = { "project.godot" },
  -- Custom on_attach is handled in lspconfig.lua setup
}
