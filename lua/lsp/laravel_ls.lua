---@type table<string, vim.lsp.Config>
return {
  laravel_ls = {
    cmd = { vim.fn.stdpath("data") .. "/mason/bin/laravel-ls" },
    filetypes = { "php", "blade" },
    root_markers = { "artisan" },
    init_options = {
      php = {
        bin = "/home/d7om/.config/herd-lite/bin/php",
      },
    },
  },
}
