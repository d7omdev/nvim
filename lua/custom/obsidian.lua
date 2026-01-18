local M = {}

function M.follow_link()
  local ok, obsidian = pcall(require, "obsidian")
  if not ok then
    vim.notify("Obsidian.nvim not loaded", vim.log.levels.WARN)
    return
  end
  obsidian.util.gf_passthrough()
end

return M
