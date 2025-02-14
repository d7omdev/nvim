-- From: https://github.com/bassamsdata/nvim/blob/81e4c348140db5ee8f5786f10a67e20392f2c0fa/lua/plugins/minipick.lua
if vim.env.NVIM_TESTING then
  return {}
end

return {
  {
    "echasnovski/mini.pick",
    dependencies = {
      { "echasnovski/mini.extra", opts = {} },
      { "echasnovski/mini.visits", opts = {} },
      { "echasnovski/mini.fuzzy", opts = {} },
    },
    cmd = "Pick",
    config = function()
      local MiniPick = require("mini.pick")
      local MiniExtra = require("mini.extra")
      require("custom.multi-grep").setup()
      vim.ui.select = require("mini.pick").ui_select

      -- copy the item under the cursor
      local copy_to_register = {
        char = "<C-y>",
        func = function()
          local line = vim.fn.line(".")
          local current_line = vim.fn.getline(line)
          vim.fn.setreg("+", current_line)
          print("Copied '" .. current_line .. "'")
        end,
      }
      -- scrll by margin of 4 lines to not diorient
      local scroll_up = {
        char = "<C-k>",
        func = function()
          -- this is special character in insert mode press C-v then y
          -- while holding Ctrl to invoke
          vim.cmd("normal! 4")
        end,
      }
      local scroll_down = {
        char = "<C-j>",
        func = function()
          vim.cmpickd("norm! 4")
        end,
      }

      local delete_file = {
        char = "<C-d>",
        func = function()
          local path = MiniPick.get_picker_matches()[MiniPick.get_picker_match_index()]
          if path then
            os.remove(path)
            MiniPick.refresh()
          end
        end,
      }

      -- Setup 'mini.pick' with default window in the ceneter
      MiniPick.setup({
        use_cache = true,
        window = {
          prompt_prefix = " ",
          config = function()
            local height = math.floor(0.618 * vim.o.lines)
            local width = math.floor(0.618 * vim.o.columns)
            return {
              border = "single",
              anchor = "NW",
              height = height,
              width = width,
              row = math.floor(0.5 * (vim.o.lines - height)),
              col = math.floor(0.5 * (vim.o.columns - width)),
            }
          end,
        },
        mappings = {
          copy_to_register = copy_to_register,
          scroll_up_a_bit = scroll_up,
          scroll_down_a_bit = scroll_down,
          delete_file = delete_file,
          refine = "<M-r>",
        },
      })
      -- == Styles ==
      -- 1 - File picker configuration that follows cursor
      local cursor_win_config = {
        -- stylua: ignore start
        border   = "single",
        relative = "cursor",
        anchor   = "NW",
        row      = 0,
        col      = 0,
        width    = 70,
        height   = 16,
        -- stylua: ignore end
      }
      -- 2 - Right side picker configuration
      local row = function()
        local has_statusline = vim.o.laststatus > 0
        local bottom_space = vim.o.cmdheight + (has_statusline and 1 or 0)
        return vim.o.lines - bottom_space
      end
      local right_win_config = {
        -- stylua: ignore start
        border   = "single",
        relative = "editor",
        anchor   = "SE",
        -- down in the right bottom
        row      = row(),
        col      = vim.o.columns - 1,
        height   = 16,
        width    = 50,
        -- stylua: ignore end
      }
      -- 3 - Center small window
      local height = math.floor(0.40 * vim.o.lines)
      local width = math.floor(0.40 * vim.o.columns)
      local center_small = {
        border = "single",
        anchor = "NW",
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
        -- relative = "editor",
      }

      -- Create new picker to search nvim config whatever the cwd is
      MiniPick.registry.config = function()
        local opts = { source = { cwd = vim.fn.stdpath("config") } }
        return MiniPick.builtin.files({}, opts)
      end

      -- Define a new picker for the quickfix list
      MiniPick.registry.quickfix = function()
        return MiniExtra.pickers.list({ scope = "quickfix" }, {})
      end

      -- Modify the 'files' picker directly
      MiniPick.registry.files = function()
        return MiniPick.builtin.files({}, { window = { config = cursor_win_config } })
      end

      -- Modify the 'old_files' picker directly
      MiniPick.registry.oldfiles = function()
        return MiniExtra.pickers.oldfiles({}, { window = { config = cursor_win_config } })
      end

      -- Modify the 'buffers' picker directly
      MiniPick.registry.buffers = function()
        return MiniPick.builtin.buffers({}, { window = { config = right_win_config } })
      end

      -- Modify the 'old_files' picker directly
      MiniPick.registry.history = function()
        return MiniExtra.pickers.history({}, { window = { config = center_small } })
      end

      MiniPick.registry.registry = function()
        local items = vim.tbl_keys(MiniPick.registry)
        table.sort(items)
        local source = { items = items, name = "Registry", choose = function() end }
        local chosen_picker_name = MiniPick.start({ source = source })
        if chosen_picker_name == nil then
          return
        end
        return MiniPick.registry[chosen_picker_name]()
      end

      -- thanks to https://github.com/echasnovski/mini.nvim/discussions/609#
      local function create_frecency_picker(opts)
        opts = opts or {}
        local directory = opts.directory or nil -- nil means current directory
        local window_config = opts.window_config or nil -- nil means default

        return function()
          local sort = MiniVisits.gen_sort.z()
          local visit_paths = MiniVisits.list_paths(directory, { sort = sort })
          local current_file = vim.fn.expand("%")

          MiniPick.builtin.files(nil, {
            source = {
              cwd = directory,
              match = function(stritems, indices, query)
                -- Concatenate prompt to a single string
                local prompt = vim.pesc(table.concat(query))

                -- If ignorecase is on and there are no uppercase letters in prompt,
                -- convert paths to lowercase for matching purposes
                local convert_path = function(str)
                  return str
                end
                if vim.o.ignorecase and string.find(prompt, "%u") == nil then
                  convert_path = function(str)
                    return string.lower(str)
                  end
                end

                local current_file_cased = convert_path(current_file)
                local paths_length = #visit_paths

                -- Flip visit_paths so that paths are lookup keys for the index values
                local flipped_visits = {}
                for index, path in ipairs(visit_paths) do
                  local key = vim.fn.fnamemodify(path, ":.")
                  flipped_visits[convert_path(key)] = index - 1
                end

                local result = {}
                for _, index in ipairs(indices) do
                  local path = stritems[index]
                  local match_score = prompt == "" and 0 or MiniFuzzy.match(prompt, path).score
                  if match_score >= 0 then
                    local visit_score = flipped_visits[path] or paths_length
                    table.insert(result, {
                      index = index,
                      -- Give current file high value so it's ranked last
                      score = path == current_file_cased and 999999 or match_score + visit_score * 10,
                    })
                  end
                end

                table.sort(result, function(a, b)
                  return a.score < b.score
                end)

                return vim.tbl_map(function(val)
                  return val.index
                end, result)
              end,
            },
            window = { config = window_config },
          })
        end
      end

      MiniPick.registry.config_frecency = create_frecency_picker({
        directory = vim.fn.stdpath("config"),
      })

      MiniPick.registry.nvim_data = create_frecency_picker({
        directory = vim.fn.stdpath("data") .. "/lazy",
      })

      MiniPick.registry.frecency = create_frecency_picker({
        window_config = cursor_win_config,
      })

      -- this is just was an idea
      MiniPick.registry.all_frecency = create_frecency_picker({
        directories = {
          nil, -- current directory
          vim.fn.stdpath("config"),
          -- add more directories as needed
        },
        cursor_win_config = cursor_win_config,
      })

      -- MINIPICK TERMINAL
      MiniPick.registry.pick_term = function()
        local term_bufs = vim.g.nvchad_terms or {}
        local buffers = {}

        for buf, _ in pairs(term_bufs) do
          buf = tonumber(buf)
          local element = { bufnr = buf, flag = "", info = vim.fn.getbufinfo(buf)[1] }
          table.insert(buffers, element)
        end

        local bufnrs = vim.tbl_keys(term_bufs)

        if #bufnrs == 0 then
          print("No terminal buffers are opened/hidden!")
          return
        end

        local source = {
          items = buffers,
          name = "Terminal Buffers",
          choose = function(chosen_item)
            -- Open term only if its window isn't opened
            if vim.fn.bufwinid(chosen_item.bufnr) == -1 then
              local termopts = vim.g.nvchad_terms[tostring(chosen_item.bufnr)]
              require("nvterminal").display(termopts)
            end
          end,
        }

        MiniPick.start({ source = source })
      end
    end,
  },
}
