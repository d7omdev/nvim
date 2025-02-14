local MiniPick = require("mini.pick")

local M = {}
local symbol = "::"
local function create_multigrep_picker()
  return function()
    local process
    local set_items_opts = { do_match = false }
    ---@diagnostic disable-next-line: undefined-field
    local spawn_opts = { cwd = vim.uv.cwd() }

    local match = function(_, _, query)
      -- Kill previous process
      ---@diagnostic disable-next-line: undefined-field
      pcall(vim.loop.process_kill, process)

      -- For empty query, explicitly set empty items to indicate "not working"
      if #query == 0 then
        return MiniPick.set_picker_items({}, set_items_opts)
      end

      -- Get the full query string
      local full_query = table.concat(query)
      -- Split on symbol
      -- old one which doesn't need if statment: local search_pattern, file_pattern = unpack(vim.split(full_query, symbol, { plain = true }))
      local search_pattern, file_pattern = full_query:match("^(.-)" .. symbol .. "(.*)$")
      if not file_pattern then
        search_pattern = full_query
      end

      -- Build command
      local command = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
      }

      -- Add search pattern
      if search_pattern and search_pattern ~= "" then
        table.insert(command, "-e")
        table.insert(command, search_pattern)
      end

      -- Add file/dir pattern if provided
      if file_pattern and file_pattern ~= "" then
        table.insert(command, "-g")
        table.insert(command, file_pattern)
      end

      process = MiniPick.set_picker_items_from_cli(command, {
        postprocess = function(lines)
          local results = {}
          for _, line in ipairs(lines) do
            if line ~= "" then
              -- I had nightmare doing this line, I hope there will be a better way
              local file, lnum, col, text = line:match("([^:]+):(%d+):(%d+):(.*)")
              if file then
                -- Format the item in a way that default_choose can handle - yay
                results[#results + 1] = {
                  path = file,
                  lnum = tonumber(lnum),
                  col = tonumber(col),
                  text = line,
                }
              end
            end
          end
          return results
        end,
        set_items_opts = set_items_opts,
        spawn_opts = spawn_opts,
      })
    end

    return MiniPick.start({
      source = {
        items = {},
        name = "Multi Grep",
        match = match,
        show = function(buf_id, items_to_show, query)
          MiniPick.default_show(buf_id, items_to_show, query, { show_icons = true })
        end,
        choose = MiniPick.default_choose,
      },
    })
  end
end

function M.setup()
  MiniPick.registry.multigrep = create_multigrep_picker()
  vim.keymap.set("n", "<leader>fm", function()
    MiniPick.registry.multigrep()
  end)
end

return M
