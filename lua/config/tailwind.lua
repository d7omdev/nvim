local tailwind_lsp_name = "tailwindcss"
local stop_timer = nil

-- Check if cursor is inside the value of class="" or className=""
local function is_cursor_inside_class_attr()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  for attr_start, attr, val_start, value in line:gmatch('()%f[%w](className?)%s*=%s*"(.-)"()') do
    local value_start_col = line:find(attr .. '%s*=%s*"', attr_start) + #attr + 1
    if value_start_col and col >= value_start_col and col <= value_start_col + #value then
      return true
    end
  end

  return false
end

-- Start TailwindCSS LSP if not already running
local function maybe_start_tailwind()
  local clients = vim.lsp.get_clients({ name = tailwind_lsp_name, bufnr = 0 })
  local attached = #clients > 0 and clients[1].initialized and not clients[1].is_stopping()

  if not attached then
    vim.lsp.start({
      name = tailwind_lsp_name,
      cmd = { "tailwindcss-language-server", "--stdio" },
      root_dir = require("lspconfig.util").root_pattern(
        "tailwind.config.js",
        "tailwind.config.ts",
        "postcss.config.js",
        "package.json",
        ".git"
      ),
    })
  end
end

-- Stop TailwindCSS LSP after delay using libuv timer
local function delayed_stop()
  if stop_timer then
    stop_timer:stop()
    stop_timer:close()
    stop_timer = nil
  end

  stop_timer = vim.loop.new_timer()
  stop_timer:start(1000, 0, function()
    vim.schedule(function()
      local clients = vim.lsp.get_clients({ name = tailwind_lsp_name, bufnr = 0 })
      for _, client in ipairs(clients) do
        if not client.is_stopping() then
          client.stop()
        end
      end
    end)
  end)
end

-- Autocommands
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = { "*.html", "*.jsx", "*.tsx", "*.vue" },
  callback = function()
    if is_cursor_inside_class_attr() then
      maybe_start_tailwind()
    end
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = { "*.html", "*.jsx", "*.tsx", "*.vue" },
  callback = function()
    delayed_stop()
  end,
})
