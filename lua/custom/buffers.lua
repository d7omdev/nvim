-- Buffers utils
local M = {}

function M.next_buffer_in_tab()
  local current_buf = vim.api.nvim_get_current_buf()

  -- Get all buffers in the current tab
  local tab_bufs = vim.t.bufs or {}

  -- Find the index of the current buffer
  local current_index = nil
  for i, buf in ipairs(tab_bufs) do
    if buf == current_buf then
      current_index = i
      break
    end
  end

  if current_index then
    -- Cycle to the next buffer in the tab
    local next_index = current_index % #tab_bufs + 1
    local next_buf = tab_bufs[next_index]
    vim.api.nvim_set_current_buf(next_buf)
  end
end

function M.prev_buffer_in_tab()
  local current_buf = vim.api.nvim_get_current_buf()

  -- Get all buffers in the current tab
  local tab_bufs = vim.t.bufs or {}

  -- Find the index of the current buffer
  local current_index = nil
  for i, buf in ipairs(tab_bufs) do
    if buf == current_buf then
      current_index = i
      break
    end
  end

  if current_index then
    -- Cycle to the previous buffer in the tab
    local prev_index = (current_index - 2 + #tab_bufs) % #tab_bufs + 1
    local prev_buf = tab_bufs[prev_index]
    vim.api.nvim_set_current_buf(prev_buf)
  end
end

return M
