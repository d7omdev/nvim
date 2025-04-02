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

-- Function to toggle fribidi processing and remove BOM
Utils.toggle_fribidi_processing = function()
  -- Get the current buffer's content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")

  if vim.b.processed_with_fribidi then
    -- Undo the fribidi processing
    vim.cmd("%!fribidi")
    vim.b.processed_with_fribidi = false
    print("Fribidi processing reversed.")
  else
    -- Process the file with fribidi
    vim.cmd("%!fribidi")

    -- Check for BOM in the first line after processing
    lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if #lines > 0 and lines[1]:byte(1) == 0xEF and lines[1]:byte(2) == 0xBB and lines[1]:byte(3) == 0xBF then
      -- Remove BOM from first line
      lines[1] = lines[1]:sub(4)
      -- Write back to buffer
      vim.api.nvim_buf_set_lines(0, 0, 1, false, { lines[1] })
      print("BOM removed.")
    end

    -- Mark the buffer as processed
    vim.b.processed_with_fribidi = true
    print("File processed with fribidi.")
  end

  -- Save the changes
  vim.cmd("write")
end -- Map the function to a key combination, e.g., <Leader>p
vim.keymap.set("n", "<Leader>tf", function()
  Utils.toggle_fribidi_processing()
end, { noremap = true, silent = true })

-- Initialize
local function init()
  setup_commands()
end

init()

return Utils
