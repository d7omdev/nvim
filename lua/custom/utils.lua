local M = {}

_G.ToggleLspStatus = function()
  vim.g.lsp_status_expanded = not (vim.g.lsp_status_expanded or false)
  -- Force statusline update
  vim.cmd("redrawstatus")
end

function M.open_github_repo()
  local line = vim.api.nvim_get_current_line()
  local cursor_col = vim.fn.col(".") - 1 -- Get the current cursor position (column)

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

M.is_transparent_theme = function()
  return require("nvconfig").base46.transparency
end

return M
