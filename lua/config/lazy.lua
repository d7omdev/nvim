vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46_cache/"
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  rocks = {
    hererocks = true,
  },
  spec = {
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        colorscheme = "nvchad",
      },
    },
    { import = "plugins" },
  },
  ui = {
    border = "single",
  },
  defaults = {
    lazy = true, -- Enable lazy loading by default for better startup performance
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  checker = { 
    enabled = true, -- automatically check for plugin updates
    frequency = 86400, -- check once per day (in seconds)
    notify = false, -- don't notify on every check
  },
  change_detection = {
    enabled = true,
    notify = false, -- don't notify on config changes
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
  dofile(vim.g.base46_cache .. v)
end
