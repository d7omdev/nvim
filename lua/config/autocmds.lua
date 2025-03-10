local autocmd = vim.api.nvim_create_autocmd

-- Automatically sort classes in a .tsx file on save
autocmd("BufWritePost", {
  pattern = { "*.tsx", "*.vue" },
  callback = function()
    local clients = vim.lsp.get_clients()
    for _, client in ipairs(clients) do
      if client.name == "tailwindcss" then
        local lsp = require("tailwind-tools.lsp")
        lsp.sort_classes(true)
        break
      end
    end
  end,
})

local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

autocmd({ "User" }, {
  pattern = "CodeCompanionInline*",
  group = group,
  callback = function(request)
    if request.match == "CodeCompanionInlineFinished" then
      -- Format the buffer after the inline request has completed
      require("conform").format({ bufnr = request.buf })
    end
  end,
})

local gdproject = io.open(vim.fn.getcwd() .. "/project.godot", "r")
local godotserver = io.open("./godothost", "r")
if gdproject then
  io.close(gdproject)
  if godotserver then
    io.close(godotserver)
    return
  end
  vim.fn.serverstart("./godothost")
end

-- Auto save buffer on leave
autocmd("BufLeave", {
  pattern = "*",
  callback = function()
    vim.cmd("silent! wa")
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.cmd([[silent! %s/\s\+$//e]])
  end,
})

-- Setup filetype for .aliasesrc
autocmd({ "BufRead", "BufNewFile" }, {
  pattern = ".aliasesrc",
  callback = function()
    vim.bo.filetype = "zsh"
  end,
})

autocmd("FileType", {
  pattern = "hyprlang",
  callback = function()
    vim.bo.commentstring = "# %s"
  end,
})
