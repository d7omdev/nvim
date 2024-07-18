local cmp = require("cmp")
return {
  "hrsh7th/nvim-cmp",
  opts = {
    mapping = {
      ["<C-c>s"] = cmp.mapping.complete(),
    },
    window = {
      completion = {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
      },
      documentation = {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
      },
    },
  },
}
-- mapping = cmp.mapping.preset.insert({
-- ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
