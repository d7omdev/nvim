_G.Utils = {}

-- UI-related functions
function Utils.is_transparent_theme()
  return require("nvconfig").base46.transparency
end

function _G.ToggleLspStatus()
  vim.g.lsp_status_expanded = not (vim.g.lsp_status_expanded or false)
  -- Force statusline update
  vim.cmd("redrawstatus")
end

function _G.StartLiveServer()
  vim.cmd("LiveServerStart")
  vim.g.live_server_active = true
  -- Force statusline update
  vim.cmd("redrawstatus")
end

function _G.StopLiveServer()
  vim.cmd("LiveServerStop")
  vim.g.live_server_active = false
  -- Force statusline update
  vim.cmd("redrawstatus")
end

-- HTML/markup functions
function Utils.wrap_with_tag()
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
  Utils.items_select(menu_items, {
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
      -- Prompt for custom tag if user selects "Custom..."
      tag = vim.fn.input("Enter custom HTML tag: ")
    else
      tag = choice
    end

    if tag == "" then
      return
    end

    -- Extract the tag name for closing tag
    local tag_name = string.match(tag, "^([%w-]+)") or tag

    -- Create wrapped text with the selected/custom tag
    local wrapped_text = "<" .. tag .. ">" .. selected_text .. "</" .. tag_name .. ">"

    -- Replace the selection with the wrapped text
    vim.fn.setreg("x", wrapped_text)
    vim.cmd('normal! gv"xp')

    -- Report success
    vim.api.nvim_echo({ { string.format("Wrapped with <%s>", tag), "Normal" } }, false, {})
  end)
end

-- Web/URL functions
function Utils.open_github_repo()
  local line = vim.api.nvim_get_current_line()

  -- Match text inside quotes on the current line
  local repo = line:match('".-"') or line:match("'.-'")
  if not repo then
    vim.notify("No valid repo found on this line.", vim.log.levels.ERROR)
    return
  end

  -- Remove the quotes from the matched text
  repo = repo:sub(2, -2)

  -- Ensure it's in the format user/repo
  if not repo:match("^[%w._-]+/[%w._-]+$") then
    vim.notify("Invalid GitHub repo format.", vim.log.levels.ERROR)
    return
  end

  -- Construct the GitHub URL
  local url = "https://github.com/" .. repo
  vim.notify("Opening: " .. url, vim.log.levels.INFO)

  -- Open the URL in the default browser
  vim.fn.jobstart({ "xdg-open", url }, { detach = true })
end

-- Setup commands
local function setup_commands()
  vim.api.nvim_create_user_command(
    "WrapWithTag",
    Utils.wrap_with_tag,
    { range = true, desc = "Wrap visual selection with HTML tag" }
  )

  vim.api.nvim_create_user_command(
    "OpenGitHubRepo",
    Utils.open_github_repo,
    { desc = "Open GitHub repository from cursor position" }
  )
end

Utils.vertical_picker = function(picker_type)
  if not picker_type or not Snacks.picker[picker_type] then
    return vim.notify(string.format("Invalid picker type: %s", tostring(picker_type)), vim.log.levels.ERROR)
  end

  Snacks.picker[picker_type]({
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

Utils.select = function(picker_type)
  if not picker_type or not Snacks.picker[picker_type] then
    return vim.notify(string.format("Invalid picker type: %s", tostring(picker_type)), vim.log.levels.ERROR)
  end

  Snacks.picker[picker_type]({
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

Utils.items_select = function(items, opts, on_choice)
  assert(type(on_choice) == "function", "on_choice must be a function")
  opts = opts or {}

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

  ---@type snacks.picker.finder.Item[]
  return Snacks.picker.pick({
    source = "select",
    items = finder_items,
    format = Snacks.picker.format.ui_select(opts.kind, #items),
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

Utils.close_all_buffers = function()
  for _, e in ipairs(require("bufferline").get_elements().elements) do
    vim.schedule(function()
      vim.cmd("bd " .. e.id)
    end)
  end
end

-- Initialize
local function init()
  setup_commands()
end

init()

return Utils
