return {
  {
    "OXY2DEV/markview.nvim",
    event = "BufRead",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      preview = {
        filetypes = { "markdown", "codecompanion" },
        ignore_buftypes = {},
      },
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

          if not configs.mpls then
            configs.mpls = {
              default_config = {
                cmd = { "mpls", "--dark-mode", "--enable-emoji", "--no-auto", "--full-sync", "--port", "8989" },
                filetypes = { "markdown" },
                single_file_support = true,
                root_dir = function(startpath)
                  return vim.fs.dirname(vim.fs.find(".git", { path = startpath or vim.fn.getcwd(), upward = true })[1])
                end,
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
