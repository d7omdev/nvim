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

-- Listen for opencode events
autocmd("User", {
  pattern = "OpencodeEvent",
  callback = function(args)
    -- See the available event types and their properties
    vim.notify(vim.inspect(args.data))
    -- Do something interesting, like show a notification when opencode finishes responding
    if args.data.type == "session.idle" then
      vim.notify("opencode finished responding")
    end
  end,
})

-- Auto-fix and format on save for ESLint
-- local eslint_fix = vim.api.nvim_create_augroup("EslintFixOnSave", { clear = true })

-- autocmd("BufWritePre", {
--   group = eslint_fix,
--   pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.vue" },
--   callback = function()
--     local clients = vim.lsp.get_active_clients({ bufnr = 0 })
--     for _, client in ipairs(clients) do
--       if client.name == "eslint" then
--         -- Run ESLint code actions before saving
--         vim.cmd("EslintFixAll")
--         vim.lsp.buf.format({ bufnr = 0, async = false })
--         break
--       end
--     end
--   end,
-- })

autocmd("BufWritePost", {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function(args)
    local filepath = vim.fn.fnameescape(args.file)

    vim.fn.jobstart({ "bun", "run", "eslint", "--fix", filepath }, {
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(_, data)
        if data and #data > 1 then
          vim.notify(table.concat(data, "\n"), vim.log.levels.INFO, { title = "ESLint" })
        end
      end,
      on_stderr = function(_, data)
        if data and #data > 1 then
          vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR, { title = "ESLint Error" })
        end
      end,
      on_exit = function()
        -- silently reload buffer if file was modified externally
        if vim.fn.getbufinfo(args.buf)[1].loaded == 1 then
          vim.cmd("checktime " .. args.buf)
        end
      end,
    })
  end,
})
