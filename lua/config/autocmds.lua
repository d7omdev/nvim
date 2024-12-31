local autocmd = vim.api.nvim_create_autocmd

-- Automatically sort classes in a .tsx file on save
autocmd("BufWritePost", {
  pattern = { "*.tsx" },
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

-- _G.my_format_on_save = true
--
-- local function organize_imports()
--   local ft = vim.bo.filetype:gsub("react$", "")
--   if not vim.tbl_contains({ "javascript", "typescript" }, ft) then
--     return
--   end
--   local ok = vim.lsp.buf_request_sync(0, "workspace/executeCommand", {
--     command = (ft .. ".organizeImports"),
--     arguments = { vim.api.nvim_buf_get_name(0) },
--   }, 3000)
--   if not ok then
--     print("Command timeout or failed to complete.")
--   end
-- end
--
-- autocmd("BufWritePre", {
--   pattern = { "*.css", "*.html", "*.js", "*.jsx", "*.json", "*.ts", "*.tsx" },
--   callback = function()
--     if not _G.my_format_on_save then
--       return
--     end
--     require("conform").format({ async = false })
--     organize_imports()
--   end,
-- })

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
