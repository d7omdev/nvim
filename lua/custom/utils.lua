local M = {}

-- UI-related functions
function M.is_transparent_theme()
  local ok, nvconfig = pcall(require, "nvconfig")
  if not ok then
    return false
  end
  return nvconfig.base46.transparency
end

function M.toggle_lsp_status()
  vim.g.lsp_status_expanded = not (vim.g.lsp_status_expanded or false)
  vim.cmd("redrawstatus")
end

function M.start_live_server()
  local ok = pcall(vim.cmd, "LiveServerStart")
  if ok then
    vim.g.live_server_active = true
    vim.cmd("redrawstatus")
  else
    vim.notify("Failed to start live server", vim.log.levels.ERROR)
  end
end

function M.stop_live_server()
  local ok = pcall(vim.cmd, "LiveServerStop")
  if ok then
    vim.g.live_server_active = false
    vim.cmd("redrawstatus")
  else
    vim.notify("Failed to stop live server", vim.log.levels.ERROR)
  end
end

-- HTML/markup functions
function M.wrap_with_tag()
  -- Save the current visual selection
  vim.cmd('normal! "xy')
  local selected_text = vim.fn.getreg("x")

  if not selected_text or selected_text == "" then
    vim.api.nvim_echo({ { "No text selected", "ErrorMsg" } }, false, {})
    return
  end

  -- Common HTML tags
  local common_tags = {
    "div",
    "span",
    "section",
    "article",
    "header",
    "footer",
    "nav",
    "aside",
    "main",
    "p",
    "h1",
    "h2",
    "h3",
    "strong",
    "em",
    "code",
    "pre",
    "ul",
    "ol",
    "li",
    "table",
    "thead",
    "tbody",
    "tr",
    "th",
    "td",
    "a",
    "button",
    "form",
  }

  -- Create menu items for vim.ui.select
  local menu_items = vim.tbl_extend("force", common_tags, { "Custom..." })

  -- Show selection menu
  M.items_select(menu_items, {
    prompt = "Select HTML tag:",
    format_item = function(item)
      return item
    end,
  }, function(choice, idx)
    if not choice then
      return
    end

    local tag
    if choice == "Custom..." then
      tag = vim.fn.input("Enter custom HTML tag: ")
    else
      tag = choice
    end

    if tag == "" then
      return
    end

    local tag_name = string.match(tag, "^([%w-]+)") or tag
    local wrapped_text = "<" .. tag .. ">" .. selected_text .. "</" .. tag_name .. ">"

    vim.fn.setreg("x", wrapped_text)
    vim.cmd('normal! gv"xp')

    vim.api.nvim_echo({ { string.format("Wrapped with <%s>", tag), "Normal" } }, false, {})
  end)
end

-- Web/URL functions
function M.open_github_repo()
  local line = vim.api.nvim_get_current_line()

  local repo = line:match('".-"') or line:match("'.-'")
  if not repo then
    vim.notify("No valid repo found on this line.", vim.log.levels.ERROR)
    return
  end

  repo = repo:sub(2, -2)

  if not repo:match("^[%w._-]+/[%w._-]+$") then
    vim.notify("Invalid GitHub repo format.", vim.log.levels.ERROR)
    return
  end

  local url = "https://github.com/" .. repo
  vim.notify("Opening: " .. url, vim.log.levels.INFO)

  vim.fn.jobstart({ "xdg-open", url }, { detach = true })
end

-- Picker utilities
function M.vertical_picker(picker_type)
  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.picker or not snacks.picker[picker_type] then
    vim.notify(string.format("Invalid picker type: %s", tostring(picker_type)), vim.log.levels.ERROR)
    return
  end

  snacks.picker[picker_type]({
    layout = {
      layout = {
        backdrop = false,
        row = 1,
        width = 0.7,
        min_width = 80,
        height = 0.8,
        border = "none",
        box = "vertical",
        { win = "input", height = 1, border = "single", title = "{title} {live} {flags}", title_pos = "center" },
        { win = "list", height = 0.4 },
        {
          win = "preview",
          title = "{preview}",
          border = "single",
          title_pos = "center",
        },
      },
    },
  })
end

function M.select(picker_type)
  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.picker or not snacks.picker[picker_type] then
    vim.notify(string.format("Invalid picker type: %s", tostring(picker_type)), vim.log.levels.ERROR)
    return
  end

  snacks.picker[picker_type]({
    layout = {
      preview = false,
      layout = {
        backdrop = false,
        width = 0.5,
        min_width = 80,
        height = 0.4,
        min_height = 3,
        box = "vertical",
        border = "rounded",
        title = "{title}",
        title_pos = "center",
        { win = "input", height = 1, border = "bottom" },
        { win = "list", border = "none" },
        { win = "preview", title = "{preview}", height = 0.4, border = "top" },
      },
    },
  })
end

function M.items_select(items, opts, on_choice)
  assert(type(on_choice) == "function", "on_choice must be a function")
  opts = opts or {}

  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.picker then
    vim.notify("Snacks.nvim picker not available", vim.log.levels.ERROR)
    return
  end

  ---@type snacks.picker.finder.Item[]
  local finder_items = {}
  for idx, item in ipairs(items) do
    local text = (opts.format_item or tostring)(item)
    table.insert(finder_items, {
      formatted = text,
      text = idx .. " " .. text,
      item = item,
      idx = idx,
    })
  end

  local title = opts.prompt or "Select"
  title = title:gsub("^%s*", ""):gsub("[%s:]*$", "")
  local completed = false

  return snacks.picker.pick({
    source = "select",
    items = finder_items,
    format = snacks.picker.format.ui_select(opts.kind, #items),
    title = title,
    layout = {
      preview = nil,
      layout = {
        backdrop = false,
        width = 0.5,
        min_width = 80,
        height = 0.4,
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
          on_choice(item and item.item, item and item.idx)
        end)
      end,
    },
    on_close = function()
      if completed then
        return
      end
      completed = true
      vim.schedule(on_choice)
    end,
  })
end

function M.close_all_buffers()
  local ok, bufferline = pcall(require, "bufferline")
  if not ok then
    vim.notify("Bufferline not available", vim.log.levels.ERROR)
    return
  end

  for _, e in ipairs(bufferline.get_elements().elements) do
    vim.schedule(function()
      vim.cmd("bd " .. e.id)
    end)
  end
end

-- Setup user commands
vim.api.nvim_create_user_command(
  "WrapWithTag",
  M.wrap_with_tag,
  { range = true, desc = "Wrap visual selection with HTML tag" }
)

vim.api.nvim_create_user_command(
  "OpenGitHubRepo",
  M.open_github_repo,
  { desc = "Open GitHub repository from cursor position" }
)

-- Backward compatibility: export to global namespace
_G.Utils = M
_G.ToggleLspStatus = M.toggle_lsp_status
_G.StartLiveServer = M.start_live_server
_G.StopLiveServer = M.stop_live_server

return M
