return {
  "GustavEikaas/easy-dotnet.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
  cmd = "Dotnet",
  ft = { "cs", "csproj", "fsproj", "razor" },
  event = "VeryLazy",
  config = function()
    if vim.env.DOTNET_ROOT == vim.fn.expand("~/.dotnet") and vim.fn.isdirectory("/usr/share/dotnet") == 1 then
      vim.env.DOTNET_ROOT = "/usr/share/dotnet"
    end

    require("easy-dotnet").setup()
  end,
}
