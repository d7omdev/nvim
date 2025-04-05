local M = {}

-- Configuration
local config = {
  icons = {
    enabled = " ",
    sleep = " ",
    disabled = " ",
    warning = " ",
    unknown = " ",
  },
  colors = {
    enabled = "#89AF6D",
    sleep = "#AEB7D0",
    disabled = "#6272A4",
    warning = "#FFB86C",
    unknown = "#42464E",
  },
  highlights = {
    enabled = "St_copilot_enabled",
    sleep = "St_copilot_sleep",
    disabled = "St_copilot_disabled",
    warning = "St_copilot_warning",
    unknown = "St_copilot_unknown",
  },
}

-- Spinner configuration
local spinner = {
  frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
  current_frame = 1,
  timer = nil,
}

-- Setup highlight groups
local function setup_highlights()
  for state, hl_name in pairs(config.highlights) do
    local bg = "#000000" -- Default fallback
    local status_bg = vim.fn.synIDattr(vim.fn.hlID("StatusLine"), "bg#")

    -- Handle empty or invalid bg color
    if status_bg and status_bg ~= "" then
      bg = status_bg
    end

    vim.api.nvim_set_hl(0, hl_name, {
      fg = config.colors[state],
      bg = bg,
      default = true, -- This allows other colorschemes to override if needed
    })
  end
end

-- Get next spinner frame
local function get_next_spinner()
  local frame = spinner.frames[spinner.current_frame]
  spinner.current_frame = spinner.current_frame + 1
  if spinner.current_frame > #spinner.frames then
    spinner.current_frame = 1
  end
  return frame
end

-- Start spinner animation
local function start_spinner()
  if not spinner.timer then
    spinner.timer = vim.loop.new_timer()
    spinner.timer:start(
      0,
      100,
      vim.schedule_wrap(function()
        vim.cmd("redrawstatus")
      end)
    )
  end
end

-- Stop spinner animation
local function stop_spinner()
  if spinner.timer then
    spinner.timer:stop()
    spinner.timer:close()
    spinner.timer = nil
  end
end

-- Helper function to check if buffer is attached
local function is_buffer_attached()
  local buf = vim.api.nvim_get_current_buf()

  -- Handle both newer and older Neovim API
  local get_clients = vim.lsp.get_active_clients or vim.lsp.get_clients
  local clients = get_clients({ bufnr = buf })

  for _, client in pairs(clients) do
    if client.name == "copilot" then
      -- Check if buffer is attached using the available method
      if vim.lsp.buf_is_attached then
        return vim.lsp.buf_is_attached(buf, client.id)
      elseif client.attached_buffers then
        return client.attached_buffers[buf] or false
      end
      -- Default to true if we can't specifically check
      return true
    end
  end
  return false
end

function M.get_status()
  if not package.loaded["copilot"] then
    stop_spinner()
    return {
      state = "unknown",
      icon = config.icons.unknown,
      hl = config.highlights.unknown,
    }
  end

  local has_copilot_suggestion = pcall(require, "copilot.suggestion")
  local has_copilot_client, copilot_client = pcall(require, "copilot.client")
  local has_copilot_api, copilot_api = pcall(require, "copilot.api")
  local has_copilot_config, copilot_config = pcall(require, "copilot.config")

  -- Get auto trigger status more safely
  local auto_trigger = vim.b.copilot_suggestion_auto_trigger
  if auto_trigger == nil and has_copilot_config then
    auto_trigger = copilot_config.get("suggestion").auto_trigger
  end

  -- Check if disabled
  local disabled = false
  if has_copilot_client then
    pcall(function()
      disabled = copilot_client.is_disabled()
    end)
  end

  if disabled then
    stop_spinner()
    return {
      state = "disabled",
      icon = config.icons.disabled,
      hl = config.highlights.disabled,
    }
  end

  if not is_buffer_attached() then
    stop_spinner()
    return {
      state = "unknown",
      icon = config.icons.unknown,
      hl = config.highlights.unknown,
    }
  end

  -- Check warning status
  local warning = false
  if has_copilot_api then
    pcall(function()
      if copilot_api.status and copilot_api.status.data then
        warning = copilot_api.status.data.status == "Warning"
      end
    end)
  end

  if warning then
    stop_spinner()
    return {
      state = "warning",
      icon = config.icons.warning,
      hl = config.highlights.warning,
    }
  end

  -- Check loading status
  local loading = false
  if has_copilot_api then
    pcall(function()
      if copilot_api.status and copilot_api.status.data then
        loading = copilot_api.status.data.status == "InProgress"
      end
    end)
  end

  if loading then
    start_spinner()
    return {
      state = "loading",
      icon = get_next_spinner(),
      hl = config.highlights.enabled,
    }
  end

  if auto_trigger == false then
    stop_spinner()
    return {
      state = "sleep",
      icon = config.icons.sleep,
      hl = config.highlights.sleep,
    }
  end

  stop_spinner()
  return {
    state = "enabled",
    icon = config.icons.enabled,
    hl = config.highlights.enabled,
  }
end

function M.setup(user_config)
  if user_config then
    config.icons = vim.tbl_deep_extend("force", config.icons, user_config.icons or {})
    config.colors = vim.tbl_deep_extend("force", config.colors, user_config.colors or {})
    config.highlights = vim.tbl_deep_extend("force", config.highlights, user_config.highlights or {})
  end
  setup_highlights()
end

function M.cleanup()
  stop_spinner()
end

-- Initialize highlights on load
setup_highlights()

return M
