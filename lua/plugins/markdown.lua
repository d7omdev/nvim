return {
  {
    "OXY2DEV/markview.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        mpls = {},
      },
      setup = {
        mpls = function(_, opts)
          local lspconfig = require("lspconfig")
          local configs = require("lspconfig.configs")
          local util = require("lspconfig.util")

          if not configs.mpls then
            configs.mpls = {
              default_config = {
                cmd = { "mpls" },
                filetypes = { "markdown" },
                single_file_support = true,
                root_dir = require("lspconfig").util.find_git_ancestor,
                settings = {},
              },
              docs = {
                description = [[https://github.com/mhersson/mpls

 Markdown Preview Language Server (MPLS) is a language server that provides
 live preview of markdown files in your browser while you edit them in your favorite editor.
				 ]],
              },
            }
          end
          lspconfig.mpls.setup(opts)
        end,
      },
    },
  },
}
