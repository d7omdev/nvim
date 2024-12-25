local cmp = require("cmp")

require("luasnip.loaders.from_vscode").lazy_load()

-- `/` cmdline setup.
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

-- `:` cmdline setup.
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    {
      name = "cmdline",
      option = {
        ignore_cmds = { "Man", "!" },
      },
    },
  }),
})

cmp.setup({
  sources = {
    { name = "ecolog" },
  },
})

local options = require("chadrc")
options = vim.tbl_deep_extend("force", options, require("nvchad.cmp"))
require("cmp").setup(options)

return {
  -- { "hrsh7th/cmp-cmdline" },
}
