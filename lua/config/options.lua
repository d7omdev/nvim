-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

vim.g.lazygit_config = true
vim.g.node_host_prog = "$HOME/.bun/bin/neovim-node-host"
vim.b.is_lspsaga_hover = false

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

-- Disable highlighting if file is over 10 MB
vim.api.nvim_command('autocmd BufReadPost * if getfsize(expand("%:p")) > 10000 * 1024 | TSBufDisable highlight | endif')

vim.cmd([[cab Wq wq]])

-- Disable virtual text
vim.diagnostic.config({ virtual_text = false })

vim.cmd([[tnoremap <C-A-_> pwd\|wl-copy<CR><C-\><C-n>:cd <C-r>+<CR>]])
