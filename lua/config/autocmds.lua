local autocmd = vim.api.nvim_create_autocmd

-- Automatically sort classes in a .tsx file on save
autocmd("BufWritePost", {
  pattern = { "*.tsx", "*.vue" },
  callback = function()
    local clients = vim.lsp.get_clients({ name = "tailwindcss" })
    if #clients > 0 then
      local ok, lsp = pcall(require, "tailwind-tools.lsp")
      if ok and lsp.sort_classes then
        pcall(lsp.sort_classes, true)
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

-- Auto save buffer on leave (optimized with debounce)
local save_timer = nil
autocmd({ "BufLeave", "FocusLost" }, {
  pattern = "*",
  callback = function()
    -- Skip auto-save for special buffers
    if vim.bo.buftype ~= "" or vim.bo.readonly or not vim.bo.modifiable then
      return
    end
    
    -- Debounce saves
    if save_timer then
      vim.fn.timer_stop(save_timer)
    end
    save_timer = vim.fn.timer_start(200, function()
      vim.cmd("silent! update")
      save_timer = nil
    end)
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

-- Listen for opencode events
autocmd("User", {
  pattern = "OpencodeEvent",
  callback = function(args)
    if args.data and args.data.type == "session.idle" then
      vim.notify("Opencode finished responding")
    end
  end,
})

