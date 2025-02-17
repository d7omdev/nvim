if vim.env.NVIM_TESTING then
  return {}
end

-- Get the config path
local conf_path = vim.fn.stdpath("config") .. "/lua/plugins" --[[@as string]]

return {
  {
    name = "codecompanion-save",
    lazy = true,
    -- event = "LspAttach",
    dir = conf_path,
    dependencies = {
      "echasnovski/mini.pick",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- Create folder to store chats
      local Path = require("plenary.path")
      local data_path = vim.fn.stdpath("data")
      local save_folder = Path:new(data_path, "cc_chats_saves")
      if not save_folder:exists() then
        save_folder:mkdir({ parents = true })
      end

      -- Save command
      vim.api.nvim_create_user_command("CodeCompanionSave", function(opts)
        local codecompanion = require("codecompanion")
        local success, chat = pcall(function()
          return codecompanion.buf_get_chat(0)
        end)
        if not success or chat == nil then
          vim.notify(
            "Save Module: CodeCompanionSave should only be called from CodeCompanion chat buffers",
            vim.log.levels.ERROR
          )
          return
        end
        if #opts.fargs == 0 then
          vim.notify("Save Module: CodeCompanionSave requires at least 1 arg to make a file name", vim.log.levels.ERROR)
        end
        local save_name = table.concat(opts.fargs, "-") .. ".md"
        local save_path = Path:new(save_folder, save_name)
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        save_path:write(table.concat(lines, "\n"), "w")
        vim.notify(string.format("Saved %s", save_name), vim.log.levels.INFO)
      end, { nargs = "*" })

      -- Using vim.ui.select
      vim.api.nvim_create_user_command("CodeCompanionLoad", function()
        local scan = require("plenary.scandir")
        local files = scan.scan_dir(save_folder:absolute(), { hidden = false, depth = 1 })

        local items = {}
        local max_name_length = 0

        -- First pass: collect items and find longest filename
        for _, file in ipairs(files) do
          local name = vim.fn.fnamemodify(file, ":t")
          max_name_length = math.max(max_name_length, #name)
          local stat = vim.loop.fs_stat(file)
          local creation_time = os.date("%Y-%m-%d %H:%M", stat.birthtime.sec)
          items[#items + 1] = {
            name = name,
            path = file,
            rel_path = vim.fn.fnamemodify(file, ":~:."),
            created = creation_time,
          }
        end

        -- Add small padding to max_name_length
        max_name_length = max_name_length + 2

        vim.ui.select(items, {
          prompt = "Select CodeCompanion Chat to Load",
          format_item = function(item)
            local padded_name = item.name .. string.rep(" ", max_name_length - #item.name)
            return string.format("%s  |  %s  |  %s", padded_name, item.created, item.rel_path)
          end,
        }, function(choice)
          if choice then
            vim.cmd.edit(choice.path)
          end
        end)
      end, {})
    end,
  },
}

-- we can add data to the chat as well like this:
-- local chat = require("codecompanion").last_chat()
-- if chat then
--   chat:add_message({
--     role = "user",
--     content = "Add your buffer content here",
--   })
-- end
