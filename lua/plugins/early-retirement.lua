return {
  "chrisgrieser/nvim-early-retirement",
  config = true,
  event = "VeryLazy",
  opts = {
    -- If a buffer has been inactive for this many minutes, close it.
    retirementAgeMins = 5,

    -- Filetypes to ignore.
    ignoredFiletypes = {},

    -- Ignore files matching this lua pattern; empty string disables this setting.
    ignoreFilenamePattern = "",

    -- Will not close the alternate file.
    ignoreAltFile = true,

    -- Minimum number of open buffers for auto-closing to become active. E.g.,
    -- by setting this to 4, no auto-closing will take place when you have 3
    -- or fewer open buffers. Note that this plugin never closes the currently
    -- active buffer, so a number < 2 will effectively disable this setting.
    minimumBufferNum = 3,

    -- Ignore buffers with unsaved changes. If false, the buffers will
    -- automatically be written and then closed.
    ignoreUnsavedChangesBufs = false,

    -- Ignore non-empty buftypes, for example terminal buffers
    ignoreSpecialBuftypes = true,

    -- Ignore visible buffers. Buffers that are open in a window or in a tab
    -- are considered visible by vim. ("a" in `:buffers`)
    ignoreVisibleBufs = true,

    -- ignore unloaded buffers. Session-management plugin often add buffers
    -- to the buffer list without loading them.
    ignoreUnloadedBufs = false,

    -- Show notification on closing. Works with plugins like nvim-notify.
    notificationOnAutoClose = true,

    -- When a file is deleted, for example via an external program, delete the
    -- associated buffer as well. Requires Neovim >= 0.10.
    -- (This feature is independent from the automatic closing)
    deleteBufferWhenFileDeleted = false,
  },
}
