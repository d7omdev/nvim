local isTransparent = require("custom.utils").is_transparent_theme()
_G.Colors = dofile(vim.g.base46_cache .. "colors")

local M = {}
local hl = vim.api.nvim_set_hl

-- hl(0, "TelescopeBorder", { fg = "#242728", bg = "#242728" })
hl(0, "SnacksPickerInputBorder", { fg = "#242728", bg = "#242728" })
-- St_HtmlServer
hl(0, "St_HtmlServer", { fg = Colors.teal, bg = "NONE" })

local highlight_maps = {
  -- Basic mappings
  menu = {
    ["BlinkCmpMenu"] = "CmpPmenu",
    ["BlinkCmpMenuBorder"] = "CmpBorder",
    ["BlinkCmpDoc"] = "CmpDoc",
    ["BlinkCmpDocBorder"] = "CmpDocBorder",
    ["BlinkCmpMenuSelection"] = "CmpSel",
  },

  lspSaga = {
    ["HoverNormal"] = "CmpPmenu",
    ["HoverBorder"] = "CmpDocBorder",
  },

  -- Label mappings
  label = {
    ["BlinkCmpLabel"] = "CmpItemAbbr",
    ["BlinkCmpLabelMatch"] = "CmpItemAbbrMatch",
  },

  -- Additional UI elements
  ui = {
    ["BlinkCmpScrollBarThumb"] = "CmpBorder",
    ["BlinkCmpScrollBarGutter"] = "CmpPmenu",
    ["BlinkCmpSignatureHelp"] = "CmpDoc",
    ["BlinkCmpSignatureHelpBorder"] = "CmpDocBorder",
    ["BlinkCmpSignatureHelpActiveParameter"] = "CmpItemAbbrMatch",
    ["BlinkCmpGhostText"] = "CmpBorder",
    ["BlinkCmpDocSeparator"] = "CmpDocBorder",
    ["BlinkCmpDocCursorLine"] = "PmenuSel",
  },

  -- FzfLua mappings to Telescope highlights
  fzf = {
    ["FzfLuaNormal"] = "TelescopeNormal",
    ["FzfLuaBorder"] = "TelescopeBorder",
    ["FzfLuaTitle"] = "TelescopePromptTitle",
    ["FzfLuaBackdrop"] = "TelescopePromptNormal",
    ["FzfLuaPreviewNormal"] = "TelescopePreviewNormal",
    ["FzfLuaPreviewBorder"] = "TelescopePreviewBorder",
    ["FzfLuaPreviewTitle"] = "TelescopePreviewTitle",
    ["FzfLuaCursor"] = "TelescopeSelectionCaret",
    ["FzfLuaCursorLine"] = "TelescopeSelection",
    ["FzfLuaCursorLineNr"] = "TelescopeResultsLineNr",
    ["FzfLuaSearch"] = "TelescopeMatching",
    ["FzfLuaScrollBorderEmpty"] = "TelescopeBorder",
    ["FzfLuaScrollBorderFull"] = "TelescopeBorder",
    ["FzfLuaScrollFloatEmpty"] = "TelescopePromptNormal",
    ["FzfLuaScrollFloatFull"] = "TelescopePromptNormal",
    ["FzfLuaHelpNormal"] = "TelescopeNormal",
    ["FzfLuaHelpBorder"] = "TelescopeBorder",
    ["FzfLuaHeaderBind"] = "luaNumber",
    ["FzfLuaPathColNr"] = "luaNumber",
    ["FzfLuaPathLineNr"] = "TelescopeResultsLineNr",
    ["FzfLuaBufName"] = "TelescopeResultsIdentifier",
    ["FzfLuaBufId"] = "TelescopeResultsIdentifier",
    ["FzfLuaBufNr"] = "TelescopeResultsIdentifier",
    ["FzfLuaBufLineNr"] = "TelescopeResultsLineNr",
    ["FzfLuaTabTitle"] = "TelescopeMultiSelection",
    ["FzfLuaTabMarker"] = "TelescopeMultiIcon",
    ["FzfLuaDirIcon"] = "TelescopePreviewDirectory",
    ["FzfLuaDirPart"] = "TelescopeResultsComment",
    ["FzfLuaFilePart"] = "TelescopePreviewNormal",
    ["FzfLuaLiveSym"] = "TelescopeMatching",
    ["FzfLuaFzfNormal"] = "TelescopeNormal",
    ["FzfLuaFzfCursorLine"] = "TelescopeSelection",
    ["FzfLuaFzfMatch"] = "TelescopeMatching",
    ["FzfLuaFzfBorder"] = "TelescopeBorder",
    ["FzfLuaFzfScrollbar"] = "TelescopeBorder",
    ["FzfLuaFzfSeparator"] = "TelescopeResultsComment",
    ["FzfLuaFzfGutter"] = "TelescopeNormal",
    ["FzfLuaFzfHeader"] = "TelescopeResultsComment",
    ["FzfLuaFzfInfo"] = "Error",
    ["FzfLuaFzfPointer"] = "TelescopeSelection",
    ["FzfLuaFzfMarker"] = "TelescopeSelection",
    ["FzfLuaFzfSpinner"] = "TelescopeSelectionCaret",
    ["FzfLuaFzfPrompt"] = "TelescopePromptNormal",
    ["FzfLuaFzfQuery"] = "TelescopeMatching",
  },
  -- SnacksPicker mappings to Telescope highlights
  snacksPicker = {
    ["SnacksPickerBorder"] = "TelescopeBorder",
    ["SnacksPickerInput"] = "TelescopePromptNormal",
    -- ["SnacksPickerInputBorder"] = "TelescopePromptBorder",
    -- ["SnacksPickerBoxBorder"] = "TelescopeBorder",
    ["SnacksPickerTitle"] = "TelescopePromptTitle",
    ["SnacksPickerBoxTitle"] = "TelescopePromptTitle",
    ["SnacksPickerList"] = "TelescopePromptNormal",
    ["SnacksPickerPrompt"] = "TelescopePromptPrefix",
    ["SnacksPickerPreviewTitle"] = "TelescopePreviewTitle",
    ["SnacksPickerPreview"] = "TelescopePreviewNormal",
    ["SnacksPickerToggle"] = "TelescopeSelectionCaret",
    ["SnacksNormal"] = "TelescopeNormal",
    ["SnacksBackdrop"] = "TelescopeNormal",
  },

  minifiles = {
    ["MiniFilesBorder"] = "Comment",
    ["MiniFilesBorderModified"] = "TelescopeBorder",
    ["MiniFilesDirectory"] = "TelescopePreviewDirectory",
    -- ["MiniFilesFile"] = "TelescopePreviewNormal",
    ["MiniFilesNormal"] = "TelescopeNormal",
    ["MiniFilesTitle"] = "TelescopePreviewTitle",
    ["MiniFilesTitleFocused"] = "TelescopePromptTitle",
  },

  misc = {
    ["SagaBorder"] = "@symbol",
    ["MiniPickBorder"] = "TelescopeBorder",
  },
}

-- Kind mappings table
local kind_types = {
  "SuperMaven",
  "TabNine",
  "Codium",
  "Copilot",
  "TypeParameter",
  "Operator",
  "Event",
  "Value",
  "Struct",
  "EnumMember",
  "Reference",
  "Color",
  "Interface",
  "File",
  "Class",
  "Unit",
  "Enum",
  "Property",
  "Module",
  "Folder",
  "Constructor",
  "Method",
  "Keyword",
  "Type",
  "Structure",
  "Text",
  "Snippet",
  "Variable",
  "Identifier",
  "Function",
  "Constant",
  "Field",
}

function M.setup_highlights()
  for _, group in pairs(highlight_maps) do
    for blink_hl, cmp_hl in pairs(group) do
      vim.cmd(string.format("hi! link %s %s", blink_hl, cmp_hl))
    end
  end

  for _, kind in ipairs(kind_types) do
    local blink_hl = string.format("BlinkCmpKind%s", kind)
    local cmp_hl = string.format("CmpItemKind%s", kind)
    vim.cmd(string.format("hi! link %s %s", blink_hl, cmp_hl))
  end

  if isTransparent then
    hl(0, "StatusLineNC", { bg = "NONE" })
    hl(0, "TbBufOn", { bg = "#1E2122" })
    hl(0, "TbBufOnClose", { bg = "#1E2122", fg = "#CA6169" })
    hl(0, "SnacksPickerInputBorder", { fg = "#1E2122", bg = "NONE" })
  end
end

-- ========================
-- Custom highlights
-- ========================

function M.set_hl(group, fg, bg, opts)
  opts = opts or {}
  opts.fg = fg
  opts.bg = bg
  hl(0, group, opts)
end

M.statusline_bg = Snacks.util.color("StatusLine", "bg")
M.emptyspace_bg = Snacks.util.color("St_EmptySpace", "bg")

local colors = dofile(vim.g.base46_cache .. "colors")

M.highlights = {
  St_macro_recording = { fg = "#CA6169", bg = M.statusline_bg, opts = { bold = true } },
  Updates = { fg = colors.teal, bg = M.emptyspace_bg },
  St_Updates_Icon = { fg = colors.black, bg = colors.teal },
  St_Updates_sep = { fg = colors.teal, bg = M.statusline_bg },
}

function M.apply_highlights()
  for group, highlight in pairs(M.highlights) do
    M.set_hl(group, highlight.fg, highlight.bg, highlight.opts)
  end
end

M.apply_highlights()

vim.api.nvim_create_autocmd({ "ColorScheme", "BufWritePost" }, {
  pattern = { "NvThemeReload" },
  callback = function()
    M.setup_highlights()
  end,
})

return M
