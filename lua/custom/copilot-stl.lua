local M = {}

-- Configuration
local config = {
  icons = {
    enabled = " ",
    sleep = " ",
    disabled = " ",
    warning = " ",
    unknown = " ",
  },
  colors = {
    enabled = "#89AF6D",
    sleep = "#AEB7D0",
    disabled = "#6272A4",
    warning = "#FFB86C",
    -- unknown = "#CA6169",
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
    vim.api.nvim_set_hl(0, hl_name, {
      fg = config.colors[state],
      bg = vim.fn.synIDattr(vim.fn.hlID("StatusLine"), "bg#"),
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
  local clients = vim.lsp.get_active_clients()
  local buf = vim.api.nvim_get_current_buf()

  for _, client in pairs(clients) do
    if client.name == "copilot" and vim.lsp.buf_is_attached(buf, client.id) then
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

  local auto_trigger = vim.b.copilot_suggestion_auto_trigger
  if auto_trigger == nil then
    local ok, copilot_config = pcall(require, "copilot.config")
    if ok then
      auto_trigger = copilot_config.get("suggestion").auto_trigger
    end
  end

  local disabled = false
  pcall(function()
    disabled = require("copilot.client").is_disabled()
  end)

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

  local warning = false
  pcall(function()
    warning = require("copilot.api").status.data.status == "Warning"
  end)

  if warning then
    stop_spinner()
    return {
      state = "warning",
      icon = config.icons.warning,
      hl = config.highlights.warning,
    }
  end

  local loading = false
  pcall(function()
    loading = require("copilot.api").status.data.status == "InProgress"
  end)

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

setup_highlights()

return M
