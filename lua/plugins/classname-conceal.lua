local M = {}

local ns = vim.api.nvim_create_namespace("classname_conceal")
local enabled = true
local min_length = 20

-- Set Conceal highlight to blue (for the icon only)
local function set_conceal_hl()
  vim.api.nvim_set_hl(0, "Conceal", { fg = "#38BDF8", bg = "NONE", default = false })
end

-- Set after a delay to override colorscheme
vim.defer_fn(set_conceal_hl, 200)

-- Also set after colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.defer_fn(set_conceal_hl, 50)
  end,
})

local function get_class_ranges(bufnr)
  local results = {}
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return results
  end

  local trees = parser:parse()
  if not trees or #trees == 0 then
    return results
  end

  -- Helper to find strings in jsx expressions (like cn() calls)
  local function find_strings_in_node(node, depth)
    if depth > 10 then
      return
    end -- Prevent infinite recursion

    if node:type() == "string" then
      for child in node:iter_children() do
        if child:type() == "string_fragment" then
          local s_row, s_col, e_row, e_col = child:range()
          local text = vim.treesitter.get_node_text(child, bufnr)
          if #text >= min_length then
            table.insert(results, { s_row, s_col, e_row, e_col })
          end
        end
      end
    end

    -- Recursively search children
    for child in node:iter_children() do
      find_strings_in_node(child, depth + 1)
    end
  end

  local function traverse(node)
    if node:type() == "jsx_attribute" then
      for child in node:iter_children() do
        if child:type() == "property_identifier" then
          local prop_name = vim.treesitter.get_node_text(child, bufnr)
          if prop_name == "className" or prop_name == "class" then
            -- Handle both string values and jsx expressions
            for sibling in node:iter_children() do
              local sibling_type = sibling:type()

              -- Direct string: className="..."
              if sibling_type == "string" then
                for str_child in sibling:iter_children() do
                  if str_child:type() == "string_fragment" then
                    local s_row, s_col, e_row, e_col = str_child:range()
                    local text = vim.treesitter.get_node_text(str_child, bufnr)
                    if #text >= min_length then
                      table.insert(results, { s_row, s_col, e_row, e_col })
                    end
                  end
                end

              -- JSX expression: className={cn(...)}
              elseif sibling_type == "jsx_expression" then
                find_strings_in_node(sibling, 0)
              end
            end
          end
        end
      end
    end

    for child in node:iter_children() do
      traverse(child)
    end
  end

  for _, tree in ipairs(trees) do
    traverse(tree:root())
  end

  return results
end

local function set_conceal(bufnr)
  if not enabled then
    return
  end

  local ft = vim.bo[bufnr].filetype
  if not vim.tbl_contains({ "typescriptreact", "javascriptreact" }, ft) then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  -- Set conceallevel for this window
  vim.wo.conceallevel = 2
  vim.wo.concealcursor = "" -- Show when cursor on line

  local class_ranges = get_class_ranges(bufnr)

  for _, range in ipairs(class_ranges) do
    local s_row, s_col, e_row, e_col = unpack(range)
    if e_row == s_row then
      vim.api.nvim_buf_set_extmark(bufnr, ns, s_row, s_col, {
        end_line = e_row,
        end_col = e_col,
        conceal = "󱏿",
        spell = false,
      })
    end
  end
end

function M.enable()
  local group = vim.api.nvim_create_augroup("ClassNameConceal", { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
    group = group,
    pattern = { "*.tsx", "*.jsx" },
    callback = function(args)
      vim.schedule(function()
        set_conceal(args.buf)
      end)
    end,
  })

  set_conceal(vim.api.nvim_get_current_buf())
  enabled = true
  -- vim.notify("ClassName conceal enabled", vim.log.levels.INFO)
end

function M.disable()
  vim.api.nvim_clear_autocmds({ group = "ClassNameConceal" })
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    end
  end
  enabled = false
  vim.notify("ClassName conceal disabled", vim.log.levels.INFO)
end

function M.toggle()
  if enabled then
    M.disable()
  else
    M.enable()
  end
end

vim.api.nvim_create_user_command("ClassNameConcealToggle", M.toggle, {})
vim.api.nvim_create_user_command("ClassNameConcealEnable", M.enable, {})
vim.api.nvim_create_user_command("ClassNameConcealDisable", M.disable, {})

-- Auto-enable
vim.defer_fn(M.enable, 100)

return {}
