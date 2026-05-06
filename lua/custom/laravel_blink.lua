-- Blink.cmp source that wraps adalessa/laravel.nvim's nvim-cmp style source
local M = {}

function M.new()
  return setmetatable({}, { __index = M })
end

function M:enabled()
  local ok, env = pcall(function() return Laravel("laravel.core.env") end)
  return ok and env and env:isActive()
    and vim.tbl_contains({ "php", "blade", "tinker" }, vim.bo.filetype)
end

function M:get_trigger_characters()
  return { "'", '"' }
end

function M:get_completions(ctx, callback)
  local ok, cmp_source = pcall(function() return Laravel("completion") end)
  if not ok or not cmp_source then
    callback({ items = {}, is_incomplete_forward = false, is_incomplete_backward = false })
    return function() end
  end

  -- Bridge blink ctx → nvim-cmp params
  local params = {
    context = {
      cursor_before_line = ctx.line:sub(1, ctx.cursor[2]),
      filetype = vim.bo.filetype,
    },
  }

  cmp_source:complete(params, function(result)
    local items = (result and result.items) or {}
    -- Convert nvim-cmp items to blink items
    local blink_items = vim.tbl_map(function(item)
      return {
        label = item.label,
        insertText = item.insertText or item.label,
        kind = item.kind or 12, -- Value
        documentation = item.documentation and { kind = "plaintext", value = tostring(item.documentation) } or nil,
      }
    end, items)

    callback({
      items = blink_items,
      is_incomplete_forward = false,
      is_incomplete_backward = false,
    })
  end)

  return function() end
end

return M
