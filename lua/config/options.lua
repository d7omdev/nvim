-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

vim.g.lazygit_config = true
vim.g.lazyvim_php_lsp = "intelephense"
vim.g.node_host_prog = vim.fn.expand("$HOME") .. "/.bun/bin/neovim-node-host"

-- Disable unused language-host providers (silences checkhealth warnings)
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- tmux masks the real terminal (TERM_PROGRAM=tmux), so snacks.image can't auto-detect
-- kitty/ghostty graphics support. The terminal's own env vars survive into tmux, so bridge
-- them to snacks' SNACKS_<TERM> override hook to force-enable the correct protocol.
if vim.env.KITTY_WINDOW_ID then
  vim.env.SNACKS_KITTY = "1"
elseif vim.env.GHOSTTY_RESOURCES_DIR or vim.env.GHOSTTY_BIN_DIR then
  vim.env.SNACKS_GHOSTTY = "1"
end

opt.laststatus = 3

opt.clipboard = "unnamedplus"

-- Make cursor blink
opt.guicursor = {
  "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50",
  "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
  "sm:block-blinkwait175-blinkoff150-blinkon175",
}
opt.linebreak = true
-- Set tab width
opt.expandtab = false
opt.tabstop = 4
opt.shiftwidth = 4
opt.autoindent = true

vim.cmd([[cab Wq wq]])

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    max_width = 60,
    max_height = 10,
    focusable = false,
    source = "always",
  },
})

vim.cmd([[tnoremap <C-A-_> pwd\|wl-copy<CR><C-\><C-n>:cd <C-r>+<CR>]])

opt.fillchars = {
  diff = "╱",
}

opt.diffopt = {
  "internal",
  "filler",
  "closeoff",
  "context:12",
  "algorithm:histogram",
  "linematch:200",
  "indent-heuristic",
}

opt.fillchars:append({ eob = " " })

vim.loader.enable()

-- Performance optimizations
opt.updatetime = 200 -- Faster completion and diagnostics
opt.timeoutlen = 300 -- Faster which-key popup
opt.redrawtime = 1500 -- Time in ms for redrawing display
opt.ttimeoutlen = 10 -- Faster key sequence completion
opt.lazyredraw = false -- Don't use lazyredraw (can cause issues with some plugins)

-- Better search performance
opt.inccommand = "split" -- Show preview of substitutions

-- Scss syntax highlighting in Vue files (lazy loaded)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "vue",
  once = true,
  callback = function()
    vim.cmd([[syntax include @scss syntax/scss.vim]])
    vim.cmd([[syntax region vueStyle matchgroup=vueTag start=/<style\s*lang="scss"\s*scoped\s*>/ end=/<\/style>/ contains=@scss keepend]])
  end,
})

opt.exrc = true
opt.secure = true

vim.g.suda_smart_edit = 1
