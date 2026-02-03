local M = {}

local ns_id = vim.api.nvim_create_namespace("claude_inline")
local state = {
  active = false,
  bufnr = nil,
  start_line = nil,
  end_line = nil,
  original_text = nil,
  new_text = nil,
  extmark_id = nil,
  virt_text_id = nil,
}

-- Setup highlight groups
local function setup_highlights()
  vim.api.nvim_set_hl(0, "ClaudeInlineApply", {
    bg = "#2d3a2d",
    fg = "#a3d9a5",
  })
  vim.api.nvim_set_hl(0, "ClaudeInlineReject", {
    bg = "#3a2d2d",
    fg = "#d9a3a3",
  })
  vim.api.nvim_set_hl(0, "ClaudeInlineNew", {
    bg = "#2a2f3a",
    fg = "#b4c9d8",
  })
  vim.api.nvim_set_hl(0, "ClaudeInlineThinking", {
    fg = "#9ca3bc",
    italic = true,
  })
end

-- Initialize highlights
setup_highlights()

-- Get visual selection (must be called while still in visual mode)
local function get_visual_selection()
  -- Force update of marks
  vim.cmd('normal! "vy')
  local text = vim.fn.getreg("v")

  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  local start_line = start_pos[2] - 1
  local start_col = start_pos[3] - 1
  local end_line = end_pos[2] - 1
  local end_col = end_pos[3]

  return text, bufnr, start_line, end_line, start_col, end_col
end

-- Get minimal context
local function get_file_context(bufnr, start_line, end_line)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

  -- Get only 5 lines before and after
  local context_start = math.max(0, start_line - 5)
  local context_end = math.min(vim.api.nvim_buf_line_count(bufnr), end_line + 5)
  local context_lines = vim.api.nvim_buf_get_lines(bufnr, context_start, context_end, false)
  local surrounding_context = table.concat(context_lines, "\n")

  -- Get diagnostics (only errors)
  local diagnostics = vim.diagnostic.get(bufnr, {
    lnum = start_line,
    end_lnum = end_line,
    severity = vim.diagnostic.severity.ERROR,
  })
  local diag_text = {}
  for _, d in ipairs(diagnostics) do
    table.insert(diag_text, d.message)
  end

  return {
    filename = vim.fn.fnamemodify(filepath, ":t"),
    filetype = filetype,
    surrounding_context = surrounding_context,
    diagnostics = table.concat(diag_text, "; "),
  }
end

-- Clear virtual text and highlights
local function clear_virtual_text()
  if state.virt_text_id then
    vim.api.nvim_buf_del_extmark(state.bufnr, ns_id, state.virt_text_id)
    state.virt_text_id = nil
  end
  if state.extmark_id then
    vim.api.nvim_buf_del_extmark(state.bufnr, ns_id, state.extmark_id)
    state.extmark_id = nil
  end
end

-- Show diff with virtual text
local function show_diff()
  if not state.bufnr or not state.new_text then
    return
  end

  -- Highlight the original selection
  state.extmark_id = vim.api.nvim_buf_set_extmark(state.bufnr, ns_id, state.start_line, 0, {
    end_line = state.end_line + 1,
    hl_group = "DiffDelete",
    hl_eol = true,
  })

  -- Show new text as virtual text
  local new_lines = vim.split(state.new_text, "\n")
  local virt_lines = {}

  for i, line in ipairs(new_lines) do
    local line_parts = {
      { "  " .. line, "ClaudeInlineNew" },
    }
    if i == 1 then
      table.insert(line_parts, { "  ", "Normal" })
      table.insert(line_parts, { " ga: Apply ", "ClaudeInlineApply" })
      table.insert(line_parts, { " ", "Normal" })
      table.insert(line_parts, { " gr: Reject ", "ClaudeInlineReject" })
    end
    table.insert(virt_lines, line_parts)
  end

  state.virt_text_id = vim.api.nvim_buf_set_extmark(state.bufnr, ns_id, state.end_line, 0, {
    virt_lines = virt_lines,
    virt_lines_above = false,
  })
end

-- Show thinking/processing indicator
local function show_thinking(line)
  state.virt_text_id = vim.api.nvim_buf_set_extmark(state.bufnr, ns_id, line, 0, {
    virt_text = { { " 󰚩 Claude is thinking... ", "ClaudeInlineThinking" } },
    virt_text_pos = "eol",
  })
end

-- Apply changes
local function apply_changes()
  if not state.active or not state.new_text then
    return
  end

  local new_lines = vim.split(state.new_text, "\n")
  vim.api.nvim_buf_set_lines(state.bufnr, state.start_line, state.end_line + 1, false, new_lines)

  clear_virtual_text()
  state.active = false
  vim.notify("✓ Changes applied", vim.log.levels.INFO)
end

-- Reject changes
local function reject_changes()
  if not state.active then
    return
  end

  clear_virtual_text()
  state.active = false
  vim.notify("✗ Changes rejected", vim.log.levels.WARN)
end

-- Call claude-code API
local function call_claude(text, prompt, context, callback)
  local diag = context.diagnostics ~= "" and "\nErrors: " .. context.diagnostics or ""

  -- Minimal prompt
  local full_prompt = string.format(
    [[Task: %s
File: %s%s

```%s
%s
```

Return only modified code.]],
    prompt,
    context.filename,
    diag,
    context.filetype,
    text
  )

  -- Create temp file for stdin
  local tmpfile = vim.fn.tempname()
  local f = io.open(tmpfile, "w")
  if f then
    f:write(full_prompt)
    f:close()
  end

  local stdout_data = {}
  local stderr_data = {}

  -- Call claude with timeout
  vim.fn.jobstart(string.format("timeout 30s cat %s | claude", tmpfile), {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(stdout_data, data)
        -- Update thinking indicator with progress
        vim.schedule(function()
          if state.virt_text_id then
            pcall(vim.api.nvim_buf_del_extmark, state.bufnr, ns_id, state.virt_text_id)
            state.virt_text_id = vim.api.nvim_buf_set_extmark(state.bufnr, ns_id, state.end_line, 0, {
              virt_text = { { " 󰚩 Receiving... ", "ClaudeInlineThinking" } },
              virt_text_pos = "eol",
            })
          end
        end)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(stderr_data, data)
      end
    end,
    on_exit = function(_, exit_code)
      os.remove(tmpfile)

      if exit_code ~= 0 then
        local err = table.concat(stderr_data, "\n")
        vim.schedule(function()
          vim.notify("Claude error: " .. (err ~= "" and err or "timeout"), vim.log.levels.ERROR)
          clear_virtual_text()
          state.active = false
        end)
        return
      end

      local output = table.concat(stdout_data, "\n")
      local code_match = output:match("```[%w]*\n(.-)```")
      local result = code_match or vim.trim(output)

      vim.schedule(function()
        callback(result)
      end)
    end,
  })
end

-- Main edit function
function M.edit_selection()
  -- Get selection BEFORE opening input (while still in visual mode)
  local text, bufnr, start_line, end_line, start_col, end_col = get_visual_selection()

  if not text or text == "" then
    vim.notify("No selection found", vim.log.levels.WARN)
    return
  end

  -- Get file context with diagnostics
  local context = get_file_context(bufnr, start_line, end_line)

  -- Store state
  state.bufnr = bufnr
  state.start_line = start_line
  state.end_line = end_line
  state.original_text = text
  state.active = true

  -- Exit visual mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)

  -- Get prompt from user (this exits visual mode, so we got selection first)
  vim.schedule(function()
    vim.ui.input({
      prompt = "󰚩 Claude prompt: ",
    }, function(prompt)
      if not prompt or prompt == "" then
        state.active = false
        return
      end

      -- Show thinking indicator AFTER user enters prompt
      show_thinking(end_line)

      -- Call Claude with context
      call_claude(text, prompt, context, function(result)
        state.new_text = result
        clear_virtual_text()

        vim.schedule(function()
          show_diff()

          -- Set up keymaps for apply/reject
          local opts = { buffer = bufnr, noremap = true, silent = true }
          vim.keymap.set("n", "ga", apply_changes, vim.tbl_extend("force", opts, { desc = "Apply Claude changes" }))
          vim.keymap.set("n", "gr", reject_changes, vim.tbl_extend("force", opts, { desc = "Reject Claude changes" }))
        end)
      end)
    end)
  end)
end

return M
