return {
  "barreiroleo/ltex_extra.nvim",
  ft = { "markdown", "tex" },
  dependencies = { "neovim/nvim-lspconfig" },
  config = function()
    -- Load ltex_extra and configure it
    require("ltex_extra").setup({
      load_langs = { "en-US" },
      init_check = true,
      path = vim.fn.stdpath("config") .. "/.ltex-dictionary", -- Specify a directory for storing dictionaries
      log_level = "none",
      server_opts = {
        settings = {
          ltex = {
            language = "en-US",
            dictionary = {
              ["en-US"] = vim.fn.stdpath("config") .. "/ltex-dictionary.txt",
            },
          },
        },
      },
    })
  end,
}
