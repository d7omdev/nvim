-- agentic.nvim — AI agentic chat panel with diff preview and context management

-- Parse the most recent ```text ... ``` fenced block from a list of buffer lines.
-- Returns subject (string) and body (string) or nil if not found.
local function parse_commit_block(lines)
  local start_idx, end_idx
  for i = #lines, 1, -1 do
    local l = lines[i]
    if not end_idx and l:match("^%s*```%s*$") then
      end_idx = i
    elseif end_idx and l:match("^%s*```%s*text%s*$") then
      start_idx = i
      break
    end
  end
  if not (start_idx and end_idx) or end_idx <= start_idx + 1 then
    return nil
  end

  local block = {}
  for i = start_idx + 1, end_idx - 1 do
    table.insert(block, lines[i])
  end

  local subject
  local body_lines = {}
  for _, l in ipairs(block) do
    if not subject then
      if l:match("%S") then subject = l end
    else
      table.insert(body_lines, l)
    end
  end
  if not subject then return nil end

  -- trim leading blank lines from body
  while body_lines[1] and not body_lines[1]:match("%S") do
    table.remove(body_lines, 1)
  end
  -- trim trailing blank lines
  while body_lines[#body_lines] and not body_lines[#body_lines]:match("%S") do
    table.remove(body_lines)
  end

  return subject, table.concat(body_lines, "\n")
end

-- Run git commit and surface result.
local function do_commit(subject, body, cwd)
  local args = { "git", "-C", cwd, "commit", "-m", subject }
  if body and body ~= "" then
    table.insert(args, "-m")
    table.insert(args, body)
  end
  local out = vim.fn.system(args)
  if vim.v.shell_error == 0 then
    vim.notify("Committed: " .. subject, vim.log.levels.INFO)
  else
    vim.notify("git commit failed:\n" .. out, vim.log.levels.ERROR)
  end
end

return {
  "carlos-algms/agentic.nvim",
  dependencies = {
    { "hakonharnes/img-clip.nvim", opts = {} },
  },
  opts = {
    provider = "claude-agent-acp",
    diff_preview = {
      enabled = true,
      layout = "inline",
      center_on_navigate_hunks = true,
    },
    hooks = {
      on_response_complete = function(data)
        local pending = vim.t[data.tab_page_id] and vim.t[data.tab_page_id].agentic_commit_pending
        if not pending then return end
        -- consume the flag so a second response in the same tab doesn't re-trigger
        vim.t[data.tab_page_id].agentic_commit_pending = nil
        if not data.success then
          vim.notify("Agentic response failed; commit cancelled.", vim.log.levels.ERROR)
          return
        end

        vim.schedule(function()
          local registry = require("agentic.session_registry")
          local session = registry.sessions[data.tab_page_id]
          if not session or not session.widget then
            vim.notify("No agentic session to read commit message from.", vim.log.levels.ERROR)
            return
          end
          local chat_buf = session.widget.buf_nrs.chat
          local lines = vim.api.nvim_buf_get_lines(chat_buf, 0, -1, false)
          local subject, body = parse_commit_block(lines)
          if not subject then
            vim.notify("Could not find a ```text commit block in the response.", vim.log.levels.ERROR)
            return
          end

          local preview_text = subject
          if body and body ~= "" then preview_text = preview_text .. "\n\n" .. body end
          local preview_item = { text = preview_text, ft = "gitcommit" }

          local items = {
            { idx = 1, text = "Approve — commit now",  action = "commit", preview = preview_item },
            { idx = 2, text = "Edit subject",           action = "edit",   preview = preview_item },
            { idx = 3, text = "Cancel",                 action = "cancel", preview = preview_item },
          }

          local ok_snacks, Snacks = pcall(require, "snacks")
          if not ok_snacks or not Snacks.picker then
            -- fallback to vim.ui.select if snacks isn't available
            vim.ui.select({ "Approve", "Edit subject", "Cancel" }, {
              prompt = "Apply this commit?\n\n" .. preview_text .. "\n",
            }, function(choice)
              if choice == "Approve" then
                do_commit(subject, body, pending.cwd)
              elseif choice == "Edit subject" then
                vim.ui.input({ prompt = "Subject: ", default = subject }, function(new_subject)
                  if new_subject and new_subject ~= "" then
                    do_commit(new_subject, body, pending.cwd)
                  else
                    vim.notify("Commit cancelled.", vim.log.levels.WARN)
                  end
                end)
              else
                vim.notify("Commit cancelled.", vim.log.levels.WARN)
              end
            end)
            return
          end

          Snacks.picker.pick({
            source = "agentic_commit_confirm",
            title = "Confirm commit",
            items = items,
            layout = {
              layout = {
                backdrop = false,
                width = 0.45,
                min_width = 50,
                height = 0.4,
                min_height = 12,
                box = "vertical",
                border = "rounded",
                title = "{title}",
                title_pos = "center",
                { win = "input",   height = 1, border = "bottom" },
                { win = "list",    height = 3, border = "none" },
                { win = "preview", title = "{preview}", border = "top" },
              },
            },
            preview = "preview",
            format = function(item) return { { item.text, "SnacksPickerLabel" } } end,
            confirm = function(picker, item)
              picker:close()
              if not item then return end
              if item.action == "commit" then
                do_commit(subject, body, pending.cwd)
              elseif item.action == "edit" then
                vim.ui.input({ prompt = "Subject: ", default = subject }, function(new_subject)
                  if new_subject and new_subject ~= "" then
                    do_commit(new_subject, body, pending.cwd)
                  else
                    vim.notify("Commit cancelled.", vim.log.levels.WARN)
                  end
                end)
              else
                vim.notify("Commit cancelled.", vim.log.levels.WARN)
              end
            end,
          })
        end)
      end,
    },
  },

  keys = {
    {
      "<C-\\>",
      function() require("agentic").toggle() end,
      mode = { "n", "v", "i" },
      desc = "Toggle Agentic Chat",
    },
    {
      "<M-\\>",
      function() require("agentic").add_selection_or_file_to_context() end,
      mode = { "n", "v" },
      desc = "Add file or selection to Agentic context",
    },
    {
      "<C-,>",
      function() require("agentic").new_session() end,
      mode = { "n", "v", "i" },
      desc = "New Agentic Session",
    },
    {
      "<A-i>r",
      function() require("agentic").restore_session() end,
      desc = "Agentic Restore session",
      silent = true,
      mode = { "n", "v", "i" },
    },
    {
      "<leader>ad",
      function() require("agentic").add_current_line_diagnostics() end,
      desc = "Add current line diagnostic to Agentic",
      mode = { "n" },
    },
    {
      "<leader>aD",
      function() require("agentic").add_buffer_diagnostics() end,
      desc = "Add all buffer diagnostics to Agentic",
      mode = { "n" },
    },
    -- suggest a conventional commit message from staged diff, then ask for approval before committing
    {
      "<leader>ac",
      function()
        local cwd = vim.fn.getcwd()
        local diff = vim.fn.system({ "git", "-C", cwd, "diff", "--staged" })
        if vim.v.shell_error ~= 0 then
          vim.notify("Not a git repo or git failed", vim.log.levels.ERROR)
          return
        end
        if diff == nil or diff:match("^%s*$") then
          vim.notify("No staged changes. Run `git add` first.", vim.log.levels.WARN)
          return
        end

        local prompt = table.concat({
          "You are a senior engineer writing a Conventional Commit message.",
          "",
          "Analyze the staged diff below and produce ONLY a commit message in this exact shape,",
          "wrapped in a single fenced ```text block:",
          "",
          "```text",
          "<type>(<optional scope>): <imperative summary <= 72 chars>",
          "",
          "- bullet describing a concrete change",
          "- another bullet",
          "```",
          "",
          "Rules:",
          "- type ∈ { feat, fix, refactor, docs, test, chore, perf, ci, style, build }",
          "- lowercase subject, no trailing period",
          "- bullets describe behavior or files changed, terse, present tense",
          "- no AI/Claude co-author trailers",
          "",
          "DO NOT run any shell or git command. DO NOT call any tool.",
          "Output the fenced ```text block and nothing else. Neovim will handle the commit",
          "with explicit user approval.",
          "",
          "--- BEGIN STAGED DIFF ---",
          diff,
          "--- END STAGED DIFF ---",
        }, "\n")

        local agentic = require("agentic")
        agentic.open({ auto_add_to_context = false, focus_prompt = true })

        vim.schedule(function()
          local ok, registry = pcall(require, "agentic.session_registry")
          if not ok then
            vim.notify("agentic session_registry unavailable", vim.log.levels.ERROR)
            return
          end
          local tab = vim.api.nvim_get_current_tabpage()
          local session = registry.sessions[tab]
          if not session or not session.widget then
            vim.notify("No active agentic session in this tab", vim.log.levels.ERROR)
            return
          end

          local function send()
            -- mark this tab so on_response_complete knows to handle the commit flow
            vim.t[tab].agentic_commit_pending = { cwd = cwd }
            local input_buf = session.widget.buf_nrs.input
            local lines = vim.split(prompt, "\n", { plain = true })
            vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, lines)
            session.widget:_submit_input()
          end

          if session.on_session_ready then
            session:on_session_ready(send)
          else
            send()
          end
        end)
      end,
      desc = "Agentic: suggest commit message and confirm",
      mode = { "n" },
    },
  },
}
