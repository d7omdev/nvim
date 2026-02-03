local M = {}

local ns_id = vim.api.nvim_create_namespace("ai_inline")
local config = {
  provider = "claude",
  model = nil,
  providers = {
    claude = { cmd = "claude", model_flag = "--model", label = "Claude" },
    codex = {
      cmd = "codex",
      label = "Codex",
      global_args = {
        "exec",
        "-c",
        "features.shell_tool=false",
        "-c",
        "features.exec_policy=false",
        "--skip-git-repo-check",
      },
      model_flag = "--model",
      output_arg = "--output-last-message",
      prompt_prefix = [[You are a text transformation tool.
Return ONLY the modified code.
No explanations. No markdown.
Do not ask to execute commands.]],
    },
  },
  presets = {
    { label = "Claude", provider = "claude", model = nil },
    { label = "Codex", provider = "codex", model = nil },
  },
  state_file = vim.fn.stdpath("state") .. "/claude-inline.json",
}
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

local function load_persisted_state()
  local f = io.open(config.state_file, "r")
  if not f then
    return
  end

  local ok, data = pcall(vim.fn.json_decode, f:read("*a"))
  f:close()
  if not ok or type(data) ~= "table" then
    return
  end

  if type(data.provider) == "string" and config.providers[data.provider] then
    config.provider = data.provider
  end
  if data.model ~= nil then
    config.model = data.model
  end
end

local function save_persisted_state()
  local f = io.open(config.state_file, "w")
  if not f then
    return
  end
  f:write(vim.fn.json_encode({ provider = config.provider, model = config.model }))
  f:close()
end

local function provider_label()
  local provider = config.providers[config.provider]
  if not provider or not provider.label then
    return "LLM"
  end
  return provider.label
end

local function extract_last_fenced_block(output)
  local last = nil
  for block in output:gmatch("```[%w]*\n(.-)```") do
    last = block
  end
  return last
end

local function extract_last_tagged_block(output, tag)
  local open_tag = "<<<" .. tag .. ">>>"
  local close_tag = "<<<END_" .. tag .. ">>>"
  local last = nil
  local pattern = vim.pesc(open_tag) .. "\n(.-)\n" .. vim.pesc(close_tag)
  for block in output:gmatch(pattern) do
    last = block
  end
  return last
end

local function set_provider_model(provider, model)
  if not config.providers[provider] then
    vim.notify("Unknown provider: " .. provider, vim.log.levels.ERROR)
    return
  end
  config.provider = provider
  config.model = model ~= "" and model or nil
  save_persisted_state()

  local model_suffix = config.model and (" (" .. config.model .. ")") or ""
  vim.notify("Model set to " .. provider_label() .. model_suffix, vim.log.levels.INFO)
end

function M.select_model()
  local choices = {}
  local current_label = provider_label()
  if config.model and config.model ~= "" then
    current_label = current_label .. " (" .. config.model .. ")"
  end

  table.insert(choices, { label = "Current: " .. current_label, current = true })
  for _, preset in ipairs(config.presets) do
    table.insert(choices, preset)
  end
  table.insert(choices, { label = "Custom...", custom = true })

  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.picker then
    vim.notify("Snacks.nvim picker not available", vim.log.levels.ERROR)
    return
  end

  local finder_items = {}
  for idx, item in ipairs(choices) do
    local text = item.label
    table.insert(finder_items, {
      formatted = text,
      text = idx .. " " .. text,
      item = item,
      idx = idx,
    })
  end

  local completed = false

  snacks.picker.pick({
    source = "select",
    items = finder_items,
    format = snacks.picker.format.ui_select({
      kind = nil,
      format_item = function(item)
        return item.label
      end,
    }),
    title = "Select LLM model",
    layout = {
      preview = nil,
      layout = {
        backdrop = false,
        width = 0.5,
        min_width = 60,
        height = 0.35,
        min_height = 3,
        box = "vertical",
        border = "rounded",
        title = "{title}",
        title_pos = "center",
        { win = "input", height = 1, border = "bottom" },
        { win = "list", border = "none" },
      },
    },
    actions = {
      confirm = function(picker, item)
        if completed then
          return
        end
        completed = true
        picker:close()
        vim.schedule(function()
          local choice = item and item.item or nil
          if not choice or choice.current then
            return
          end

          if choice.custom then
            vim.ui.input({ prompt = "Provider (claude|codex): ", default = config.provider }, function(provider)
              if not provider or provider == "" then
                return
              end
              provider = vim.trim(provider)
              if not config.providers[provider] then
                vim.notify("Unknown provider: " .. provider, vim.log.levels.ERROR)
                return
              end

              vim.ui.input({ prompt = "Model (optional): ", default = config.model or "" }, function(model)
                if model == nil then
                  return
                end
                set_provider_model(provider, vim.trim(model))
              end)
            end)
            return
          end

          set_provider_model(choice.provider, choice.model)
        end)
      end,
    },
    on_close = function()
      if completed then
        return
      end
      completed = true
    end,
  })
end

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
load_persisted_state()

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
    virt_text = { { " 󰚩 " .. provider_label() .. " is thinking... ", "ClaudeInlineThinking" } },
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
local function build_command(tmpfile, outputfile)
  local provider = config.providers[config.provider]
  if not provider then
    return nil, "Unknown provider: " .. tostring(config.provider)
  end

  local cmd_parts = { provider.cmd }
  if provider.global_args then
    for _, arg in ipairs(provider.global_args) do
      table.insert(cmd_parts, vim.fn.shellescape(arg))
    end
  end
  if provider.extra_args then
    for _, arg in ipairs(provider.extra_args) do
      table.insert(cmd_parts, vim.fn.shellescape(arg))
    end
  end
  if provider.output_arg and outputfile then
    table.insert(cmd_parts, vim.fn.shellescape(provider.output_arg))
    table.insert(cmd_parts, vim.fn.shellescape(outputfile))
  end
  if provider.model_flag and config.model and config.model ~= "" then
    table.insert(cmd_parts, vim.fn.shellescape(provider.model_flag))
    table.insert(cmd_parts, vim.fn.shellescape(config.model))
  end

  local cmd_with_args = table.concat(cmd_parts, " ")

  local shell_cmd = string.format(
    "timeout 30s sh -c %s",
    vim.fn.shellescape("cat " .. vim.fn.shellescape(tmpfile) .. " | " .. cmd_with_args)
  )

  return shell_cmd, nil
end

local function call_llm(text, prompt, context, callback)
  local diag = context.diagnostics ~= "" and "\nErrors: " .. context.diagnostics or ""
  local provider = config.providers[config.provider]
  local prefix = ""
  if provider and provider.prompt_prefix then
    prefix = provider.prompt_prefix .. "\n\n"
  end

  -- Minimal prompt
  local full_prompt = string.format(
    [[%sTask: %s
File: %s%s

```%s
%s
```

Return only modified code.
Output format:
<<<CODE>>>
<modified code here>
<<<END_CODE>>>]],
    prefix,
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

  local outputfile = nil
  if provider and provider.output_arg then
    outputfile = vim.fn.tempname() .. "-output.txt"
  end

  local cmd, err = build_command(tmpfile, outputfile)
  if not cmd then
    os.remove(tmpfile)
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  -- Call provider with timeout
  vim.fn.jobstart(cmd, {
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
          vim.notify(provider_label() .. " error: " .. (err ~= "" and err or "timeout"), vim.log.levels.ERROR)
          clear_virtual_text()
          state.active = false
        end)
        return
      end

      local output = table.concat(stdout_data, "\n")
      if outputfile then
        local f = io.open(outputfile, "r")
        if f then
          output = f:read("*a") or output
          f:close()
        end
        os.remove(outputfile)
      end
      local tagged = extract_last_tagged_block(output, "CODE")
      local code_match = extract_last_fenced_block(output)
      local result = tagged or code_match or vim.trim(output)

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
      prompt = "󰚩 " .. provider_label() .. " prompt: ",
    }, function(prompt)
      if not prompt or prompt == "" then
        state.active = false
        return
      end

      -- Show thinking indicator AFTER user enters prompt
      show_thinking(end_line)

      -- Call Claude with context
      call_llm(text, prompt, context, function(result)
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
