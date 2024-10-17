return {
  "coffebar/neovim-project",
  event = "VeryLazy",
  opts = {
    projects = { -- define project roots
      "~/Projects/*",
      "~/.config/*",
    },
    last_session_on_startup = false,
  },
  init = function()
    -- enable saving the state of plugins in the session
    vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
  end,
  dependencies = {
    { "Shatur/neovim-session-manager" },
  },
  lazy = false,
  priority = 100,
}
