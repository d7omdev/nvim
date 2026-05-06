---@type table<string, vim.lsp.Config>
return {
  -- ts_ls configuration
  ts_ls = {
    enabled = false,
  },

  -- vtsls configuration (for Vue projects)
  vtsls = {
    enabled = vim.fn.filereadable("src/App.vue") == 1 or vim.fn.filereadable("nuxt.config.ts") == 1,
  },

  -- ESLint configuration
  eslint = {
    enabled = false,
    settings = {
      format = { enable = true },
    },
  },

  -- Volar (Vue) configuration
  volar = {
    init_options = {
      vue = {
        hybridMode = true,
      },
    },
  },

  -- TSGo (experimental TypeScript LSP)
  tsgo = {
    cmd = { "tsgo", "--lsp", "--stdio" },
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
    root_markers = {
      "tsconfig.json",
      "jsconfig.json",
      "package.json",
      ".git",
      "tsconfig.base.json",
    },
  },
}
