local cmp = require("cmp")

require("luasnip.loaders.from_vscode").lazy_load()

vim.api.nvim_set_hl(0, "CmpNormal", { bg = "#131320", fg = "#D7D7D7" })
vim.api.nvim_set_hl(0, "CmpBorder", { bg = "#131320", fg = "#D7D7D7" })

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
local function border(hl_name)
  return {
    { "╭", hl_name },
    { "─", hl_name },
    { "╮", hl_name },
    { "│", hl_name },
    { "╯", hl_name },
    { "─", hl_name },
    { "╰", hl_name },
    { "│", hl_name },
  }
end

return {
  { "hrsh7th/cmp-cmdline" },
  {
    "hrsh7th/nvim-cmp",
    opts = {
      mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
      },
      window = {
        completion = {
          border = border("CmpBorder"),
          winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
        },
        documentation = {
          border = border("CmpBorder"),
          winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
        },
      },
    },
  },
}
