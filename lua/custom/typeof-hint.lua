-- Show virtual line below `typeof X` with an up-arrow pointing to the keyword,
-- annotated with the resolved type from the LSP.

local M = {}

local ns = vim.api.nvim_create_namespace("typeof_hint")
local pending_token = 0

local function extract_code_block(text)
  -- Prefer the first fenced code block (LSP hover typically wraps the signature in ```typescript ... ```).
  local block = text:match("```%w*\n(.-)```")
  if block then return block end
  return text
end

local function strip_to_type(text)
  if not text or text == "" then return nil end
  local body = extract_code_block(text)
  -- Drop parenthesized prefix tags like "(alias) ", "(property) ", "(parameter) ".
  body = body:gsub("^%s*%b()%s*", "")

  -- Case 1: `const|let|var NAME: TYPE` (TYPE may span multiple lines).
  local rest = body:match("^%s*[%w_%$]+%s+[%w_%$]+%s*:%s*(.*)$")
  if rest then return rest end

  -- Case 2: `function NAME(args): ret` → `(args) => ret`.
  local args, ret = body:match("^%s*function%s+[%w_%$]+%s*(%b())%s*:%s*(.*)$")
  if args and ret then
    return args .. " => " .. ret
  end

  -- Case 3: `class NAME ...` — typeof of a class is its constructor; just label it.
  local cls = body:match("^%s*class%s+([%w_%$]+)")
  if cls then return "typeof " .. cls .. " (constructor)" end

  -- Fallback: return the trimmed body.
  return (body:gsub("^%s*(.-)%s*$", "%1"))
end

local function find_typeofs(line)
  -- Returns list of { kind = "keyof"|"typeof", col, ident_col, ident, suppress_end }
  -- `suppress_end` is the byte-end of the keyof segment so the inner `typeof` match can be discarded.
  local matches = {}

  -- Pass 1: keyof typeof X — these "own" the inner typeof.
  local keyof_spans = {}
  local init = 1
  while true do
    local s, e, ident = line:find("keyof%s+typeof%s+([%w_%$][%w_%$%.]*)", init)
    if not s then break end
    local prev = s > 1 and line:sub(s - 1, s - 1) or ""
    if not prev:match("[%w_%$]") then
      local ident_start = line:find(ident, s, true)
      table.insert(matches, {
        kind = "keyof",
        col = s - 1,
        ident_col = ident_start - 1,
        ident = ident,
      })
      table.insert(keyof_spans, { s, e })
    end
    init = e + 1
  end

  -- Pass 2: plain typeof X, skipping any inside a keyof span.
  init = 1
  while true do
    local s, e, ident = line:find("typeof%s+([%w_%$][%w_%$%.]*)", init)
    if not s then break end
    local prev = s > 1 and line:sub(s - 1, s - 1) or ""
    local inside_keyof = false
    for _, span in ipairs(keyof_spans) do
      if s >= span[1] and s <= span[2] then inside_keyof = true; break end
    end
    if not prev:match("[%w_%$]") and not inside_keyof then
      local ident_start = line:find(ident, s + 6, true)
      table.insert(matches, {
        kind = "typeof",
        col = s - 1,
        ident_col = ident_start - 1,
        ident = ident,
      })
    end
    init = e + 1
  end

  return matches
end

local function extract_keys(type_text)
  if not type_text then return nil end
  local keys = {}
  local seen = {}
  -- Match property declarations: optional `readonly`, then identifier or "literal", then `:` or `?:`.
  for key in type_text:gmatch("[\n{;,]%s*readonly%s+([%w_%$]+)%s*[%?:]") do
    if not seen[key] then table.insert(keys, key); seen[key] = true end
  end
  for key in type_text:gmatch("[\n{;,]%s*([%w_%$]+)%s*[%?:]") do
    if not seen[key] and key ~= "readonly" then
      table.insert(keys, key); seen[key] = true
    end
  end
  -- Also handle quoted keys: "foo": ... or 'foo': ...
  for key in type_text:gmatch("[\n{;,]%s*[\"']([^\"']+)[\"']%s*[%?:]") do
    if not seen[key] then table.insert(keys, key); seen[key] = true end
  end
  if #keys == 0 then return nil end
  local parts = {}
  for _, k in ipairs(keys) do
    if k:match("^[%a_%$][%w_%$]*$") then
      table.insert(parts, '"' .. k .. '"')
    else
      table.insert(parts, '"' .. k .. '"')
    end
  end
  return table.concat(parts, " | ")
end

local function request_type(bufnr, row, col, callback)
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    position = { line = row, character = col },
  }
  vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(err, result)
    if err or not result or not result.contents then
      callback(nil)
      return
    end
    local contents = result.contents
    local text
    if type(contents) == "string" then
      text = contents
    elseif contents.value then
      text = contents.value
    elseif type(contents) == "table" then
      local parts = {}
      for _, c in ipairs(contents) do
        if type(c) == "string" then table.insert(parts, c)
        elseif c.value then table.insert(parts, c.value) end
      end
      text = table.concat(parts, "\n")
    end
    callback(strip_to_type(text))
  end)
end

function M.refresh()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local ft = vim.bo[bufnr].filetype
  if ft ~= "typescript" and ft ~= "typescriptreact" and ft ~= "javascript" and ft ~= "javascriptreact" then
    return
  end

  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
  local matches = find_typeofs(line)
  if #matches == 0 then return end

  pending_token = pending_token + 1
  local token = pending_token
  local results = {}
  local remaining = #matches

  for i, m in ipairs(matches) do
    request_type(bufnr, row, m.ident_col, function(typ)
      if token ~= pending_token then return end
      local rendered = typ
      if m.kind == "keyof" then
        local keys = extract_keys(typ)
        rendered = keys or ("keyof typeof " .. m.ident)
      end
      results[i] = { col = m.col, ident = m.ident, type = rendered, kind = m.kind }
      remaining = remaining - 1
      if remaining == 0 then
        M.render(bufnr, row, results)
      end
    end)
  end
end

local function split_lines(s)
  local out = {}
  for line in (s .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(out, line)
  end
  if #out > 0 and out[#out] == "" then table.remove(out) end
  if #out == 0 then out = { "" } end
  return out
end

function M.render(bufnr, row, results)
  -- One arrow row + N continuation rows (max across all matches).
  table.sort(results, function(a, b) return a.col < b.col end)

  local lines_per = {}
  local max_lines = 1
  for i, r in ipairs(results) do
    local body = r.type or ("typeof " .. r.ident)
    lines_per[i] = split_lines(body)
    if #lines_per[i] > max_lines then max_lines = #lines_per[i] end
  end

  local virt_lines = {}
  for li = 1, max_lines do
    local chunks = {}
    local cursor = 0
    for i, r in ipairs(results) do
      if r.col > cursor then
        table.insert(chunks, { string.rep(" ", r.col - cursor), "Normal" })
        cursor = r.col
      end
      local prefix = (li == 1) and "↑ " or "  "
      local content = lines_per[i][li] or ""
      local label = prefix .. content
      table.insert(chunks, { label, "DiagnosticHint" })
      cursor = cursor + vim.fn.strdisplaywidth(label)
    end
    table.insert(virt_lines, chunks)
  end

  pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, row, 0, {
    virt_lines = virt_lines,
    virt_lines_above = false,
  })
end

function M.setup()
  local group = vim.api.nvim_create_augroup("TypeofHint", { clear = true })
  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "BufEnter" }, {
    group = group,
    pattern = { "*.ts", "*.tsx", "*.js", "*.jsx", "*.mts", "*.cts" },
    callback = function()
      vim.defer_fn(M.refresh, 50)
    end,
  })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
    group = group,
    pattern = { "*.ts", "*.tsx", "*.js", "*.jsx", "*.mts", "*.cts" },
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    end,
  })
end

return M
