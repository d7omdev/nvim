---@type vim.lsp.Config
return {
  cmd = { "qml-language-server" },
  filetypes = { "qml", "qmljs" },
  root_markers = { "qmldir", "CMakeLists.txt", ".git", "*.pro", "*.qmlproject" },
  single_file_support = true,

  -- Ensure all capabilities are properly advertised
  capabilities = (function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.definition = {
      dynamicRegistration = true,
      linkSupport = true,
    }
    capabilities.textDocument.hover = {
      dynamicRegistration = true,
      contentFormat = { "markdown", "plaintext" },
    }
    capabilities.textDocument.completion = {
      dynamicRegistration = true,
      completionItem = {
        snippetSupport = true,
        commitCharactersSupport = true,
        documentationFormat = { "markdown", "plaintext" },
      },
    }
    return capabilities
  end)(),

  -- Initialize with build directory if available
  init_options = {
    buildDir = vim.fn.getcwd() .. "/build",
  },

  on_new_config = function(config, root_dir)
    -- Try to find build directory
    local build_dirs = { "build", "build-debug", "build-release", ".build" }
    for _, dir in ipairs(build_dirs) do
      local build_path = root_dir .. "/" .. dir
      if vim.fn.isdirectory(build_path) == 1 then
        config.init_options.buildDir = build_path
        break
      end
    end
  end,
}
