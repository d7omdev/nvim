local M = {}

-- UI-related functions
function M.is_transparent_theme()
  return require("nvconfig").base46.transparency
end

_G.ToggleLspStatus = function()
  vim.g.lsp_status_expanded = not (vim.g.lsp_status_expanded or false)
  -- Force statusline update
  vim.cmd("redrawstatus")
end

-- HTML/markup functions
function M.wrap_with_tag()
  -- Save the current visual selection
  vim.cmd('normal! "xy')
  local selected_text = vim.fn.getreg("x")

  -- If no text is selected or something went wrong, exit
  if not selected_text or selected_text == "" then
    vim.api.nvim_echo({ { "No text selected", "ErrorMsg" } }, false, {})
    return
  end

  -- Common HTML tags
  local common_tags = {
    -- Layout tags
    "div",
    "span",
    "section",
    "article",
    "header",
    "footer",
    "nav",
    "aside",
    "main",

    -- Text tags
    "p",
    "h1",
    "h2",
    "h3",
    "strong",
    "em",
    "code",
    "pre",

    -- List tags
    "ul",
    "ol",
    "li",

    -- Table tags
    "table",
    "thead",
    "tbody",
    "tr",
    "th",
    "td",

    -- Interactive tags
    "a",
    "button",
    "form",
  }

  -- Create menu items for vim.ui.select
  local menu_items = {}
  for _, tag in ipairs(common_tags) do
    table.insert(menu_items, tag)
  end
  table.insert(menu_items, "Custom...") -- Option for custom tag

  -- Show selection menu
  vim.ui.select(menu_items, {
    prompt = "Select HTML tag:",
    format_item = function(item)
      return item
    end,
  }, function(choice, idx)
    if not choice then
      return -- User cancelled
    end

    local tag
    if choice == "Custom..." then
      -- Prompt for custom tag
      tag = vim.fn.input("Enter custom HTML tag: ")
      if tag == "" then
        return
      end
    else
      tag = choice
    end

    -- Extract tag name (for the closing tag)
    local tag_name = string.match(tag, "^([%w-]+)")
    if not tag_name then
      tag_name = tag -- Fallback if regex fails
    end

    -- Create wrapped text
    local wrapped_text = "<" .. tag .. ">" .. selected_text .. "</" .. tag_name .. ">"

    -- Replace the selection with the wrapped text
    vim.fn.setreg("x", wrapped_text)
    vim.cmd('normal! gv"xp')

    -- Report success
    vim.api.nvim_echo({ { string.format("Wrapped with <%s>", tag), "Normal" } }, false, {})
  end)
end

-- Web/URL functions
function M.open_github_repo()
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
    M.wrap_with_tag,
    { range = true, desc = "Wrap visual selection with HTML tag" }
  )

  vim.api.nvim_create_user_command(
    "OpenGitHubRepo",
    M.open_github_repo,
    { desc = "Open GitHub repository from cursor position" }
  )
end

-- Initialize
local function init()
  setup_commands()
end

init()

return M
