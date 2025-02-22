return {
  "echasnovski/mini.files",
  opts = {
    mappings = {
      close = "q",
      go_in = "l",
      go_in_plus = "<CR>",
      go_out = "H",
      go_out_plus = "h",
      reset = ",",
      reveal_cwd = ".",
      show_help = "g?",
      synchronize = "s",
      trim_left = "<",
      trim_right = ">",
    },
    windows = {
      preview = true,
      width_focus = 60,
      width_preview = 60,
    },
    options = {
      use_as_default_explorer = true,
      permanent_delete = false,
    },
  },
  keys = {
    {
      "<leader>e",
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
      end,
      desc = "Open mini.files (Directory of Current File)",
    },
    {
      "<leader>B",
      function()
        require("mini.files").open(vim.uv.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
  },
  config = function(_, opts)
    -- Initialize Git status integration first
    local nsMiniFiles = vim.api.nvim_create_namespace("mini_files_git")
    local autocmd = vim.api.nvim_create_autocmd
    local _, MiniFiles = pcall(require, "mini.files")

    -- Initialize cache before it's used
    local gitStatusCache = {}
    local cacheTimeout = 2000 -- Cache timeout in milliseconds

    -- State management for visibility toggles - both start as false (hidden)
    local show_dotfiles = false
    local show_ignored = false

    -- Define mapSymbols function in proper scope
    local function mapSymbols(status)
      local statusMap = {
        [" M"] = { symbol = "󰦒", hlGroup = "MiniDiffSignChange" },
        ["M "] = { symbol = "•", hlGroup = "MiniDiffSignChange" },
        ["MM"] = { symbol = "≠", hlGroup = "MiniDiffSignChange" },
        ["A "] = { symbol = "+", hlGroup = "MiniDiffSignAdd" },
        ["AA"] = { symbol = "≈", hlGroup = "MiniDiffSignAdd" },
        ["D "] = { symbol = "-", hlGroup = "MiniDiffSignDelete" },
        ["AM"] = { symbol = "⊕", hlGroup = "MiniDiffSignChange" },
        ["AD"] = { symbol = "-•", hlGroup = "MiniDiffSignChange" },
        ["R "] = { symbol = "→", hlGroup = "MiniDiffSignChange" },
        ["U "] = { symbol = "‖", hlGroup = "MiniDiffSignChange" },
        ["UU"] = { symbol = "⇄", hlGroup = "MiniDiffSignAdd" },
        ["UA"] = { symbol = "⊕", hlGroup = "MiniDiffSignAdd" },
        ["??"] = { symbol = "?", hlGroup = "MiniDiffSignDelete" },
        ["!!"] = { symbol = "", hlGroup = "Comment" },
      }

      local result = statusMap[status] or { symbol = "?", hlGroup = "NonText" }
      return result.symbol, result.hlGroup
    end

    -- Filter functions that use the cache
    local function is_ignored(fs_entry)
      if not gitStatusCache then
        return false
      end

      local cwd = vim.fn.getcwd()
      if not gitStatusCache[cwd] then
        return false
      end

      local relative_path = fs_entry.path:gsub("^" .. vim.fn.escape(cwd, "%-%.%+%[%]%(%)%$%^") .. "/", "")
      return gitStatusCache[cwd].statusMap and gitStatusCache[cwd].statusMap[relative_path] == "!!"
    end

    local function filter_entries(fs_entry)
      local is_dot = vim.startswith(fs_entry.name, ".")
      local is_ignored_file = is_ignored(fs_entry)

      return (not is_dot or show_dotfiles) and (not is_ignored_file or show_ignored)
    end

    -- Add the filter to the initial setup options
    opts.content = {
      filter = filter_entries,
    }

    -- Now set up mini.files with the modified opts
    require("mini.files").setup(opts)

    local function fetchGitStatus(cwd, callback)
      local function on_exit(content)
        if content.code == 0 then
          callback(content.stdout)
        end
      end
      vim.system({ "git", "status", "--ignored", "--porcelain" }, { text = true, cwd = cwd }, on_exit)
    end

    local function escapePattern(str)
      return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
    end

    local function updateMiniWithGit(buf_id, gitStatusMap)
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf_id) then
          return
        end

        local nlines = vim.api.nvim_buf_line_count(buf_id)
        local cwd = vim.fn.getcwd()
        local escapedcwd = escapePattern(cwd)
        if vim.fn.has("win32") == 1 then
          escapedcwd = escapedcwd:gsub("\\", "/")
        end

        -- Clear existing highlights
        vim.api.nvim_buf_clear_namespace(buf_id, nsMiniFiles, 0, -1)

        for i = 1, nlines do
          local entry = MiniFiles.get_fs_entry(buf_id, i)
          if not entry then
            break
          end
          local relativePath = entry.path:gsub("^" .. escapedcwd .. "/", "")
          local status = gitStatusMap[relativePath]

          if status then
            local symbol, hlGroup = mapSymbols(status)
            if status == "!!" then
              -- Apply Comment highlight to the whole line
              vim.api.nvim_buf_add_highlight(buf_id, nsMiniFiles, "Comment", i - 1, 0, -1)

              -- Add the symbol at EOL
              vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
                virt_text = { { symbol, "Comment" } },
                virt_text_pos = "eol",
                priority = 2,
                hl_mode = "combine",
              })
            else
              vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
                virt_text = { { symbol, hlGroup } },
                virt_text_pos = "eol",
                priority = 2,
                hl_mode = "combine",
              })
            end
          end
        end
      end)
    end

    local function parseGitStatus(content)
      local gitStatusMap = {}
      for line in content:gmatch("[^\r\n]+") do
        local status, filePath = string.match(line, "^(..)%s+(.*)")
        local parts = {}
        for part in filePath:gmatch("[^/]+") do
          table.insert(parts, part)
        end

        local currentPath = ""
        for i, part in ipairs(parts) do
          if i == 1 then
            currentPath = part
          else
            currentPath = currentPath .. "/" .. part
          end
          -- For ignored items, propagate !! status to all parent directories
          if status == "!!" then
            gitStatusMap[currentPath] = status
          end
          -- For the actual file/folder itself
          if i == #parts then
            gitStatusMap[currentPath] = status
          end
        end
      end
      return gitStatusMap
    end

    local function is_valid_git_repo()
      if vim.fn.isdirectory(".git") == 0 then
        return false
      end
      return true
    end

    -- Toggle functions
    local toggle_dotfiles = function()
      show_dotfiles = not show_dotfiles
      require("mini.files").refresh({ content = { filter = filter_entries } })
    end

    local toggle_ignored = function()
      show_ignored = not show_ignored
      require("mini.files").refresh({ content = { filter = filter_entries } })
    end

    local function updateGitStatus(buf_id)
      if not is_valid_git_repo() then
        return
      end
      local cwd = vim.fn.expand("%:p:h")
      local currentTime = os.time()
      if gitStatusCache[cwd] and currentTime - gitStatusCache[cwd].time < cacheTimeout then
        updateMiniWithGit(buf_id, gitStatusCache[cwd].statusMap)
      else
        fetchGitStatus(cwd, function(content)
          local gitStatusMap = parseGitStatus(content)
          gitStatusCache[cwd] = {
            time = currentTime,
            statusMap = gitStatusMap,
          }
          updateMiniWithGit(buf_id, gitStatusMap)
        end)
      end
    end

    local function clearCache()
      gitStatusCache = {}
    end

    local map_split = function(buf_id, lhs, direction, close_on_file)
      local rhs = function()
        local new_target_window
        local cur_target_window = require("mini.files").get_explorer_state().target_window
        if cur_target_window ~= nil then
          vim.api.nvim_win_call(cur_target_window, function()
            vim.cmd("belowright " .. direction .. " split")
            new_target_window = vim.api.nvim_get_current_win()
          end)

          require("mini.files").set_target_window(new_target_window)
          require("mini.files").go_in({ close_on_file = close_on_file })
        end
      end

      local desc = "Open in " .. direction .. " split"
      if close_on_file then
        desc = desc .. " and close"
      end
      vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
    end

    local files_set_cwd = function()
      local cur_entry_path = MiniFiles.get_fs_entry().path
      local cur_directory = vim.fs.dirname(cur_entry_path)
      if cur_directory ~= nil then
        vim.fn.chdir(cur_directory)
      end
    end

    -- Set up autocmds
    local function augroup(name)
      return vim.api.nvim_create_augroup("MiniFiles_" .. name, { clear = true })
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local buf_id = args.data.buf_id

        vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle hidden files" })

        vim.keymap.set("n", "gi", toggle_ignored, { buffer = buf_id, desc = "Toggle ignored files" })

        vim.keymap.set("n", "gc", files_set_cwd, { buffer = buf_id, desc = "Set cwd" })

        map_split(buf_id, "<C-e>s", "horizontal", false)
        map_split(buf_id, "<C-e>v", "vertical", false)
        map_split(buf_id, "<C-w>S", "horizontal", true)
        map_split(buf_id, "<C-w>V", "vertical", true)
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesActionRename",
      callback = function(event)
        Snacks.rename.on_rename_file(event.data.from, event.data.to)
      end,
    })

    -- Set up git status autocmds
    autocmd("User", {
      group = augroup("start"),
      pattern = "MiniFilesExplorerOpen",
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        updateGitStatus(bufnr)
      end,
    })

    autocmd("User", {
      group = augroup("close"),
      pattern = "MiniFilesExplorerClose",
      callback = function()
        clearCache()
      end,
    })

    autocmd("User", {
      group = augroup("update"),
      pattern = "MiniFilesBufferUpdate",
      callback = function(sii)
        local bufnr = sii.data.buf_id
        local cwd = vim.fn.expand("%:p:h")
        if gitStatusCache[cwd] then
          updateMiniWithGit(bufnr, gitStatusCache[cwd].statusMap)
        end
      end,
    })
  end,
}
