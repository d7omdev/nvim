-- Neovim 0.12's built-in documentColor handler can crash on malformed
-- colors returned by some LSP servers. This config already uses
-- nvim-highlight-colors for previews, so disable the native handler globally.
vim.lsp.document_color.enable(false)

require("config.lazy")
require("custom.hl").setup_highlights()
