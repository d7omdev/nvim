local M = {}

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
    ["SnacksPickerInputBorder"] = "TelescopePromptBorder",
    ["SnacksPickerBoxBorder"] = "TelescopePromptBorder",
    ["SnacksPickerTitle"] = "TelescopePromptTitle",
    ["SnacksPickerBoxTitle"] = "TelescopePromptTitle",
    ["SnacksPickerList"] = "TelescopePromptNormal",
    ["SnacksPickerPrompt"] = "TelescopePromptPrefix",
    ["SnacksPickerPreviewTitle"] = "TelescopePreviewTitle",
    ["SnacksPickerPreview"] = "TelescopePreviewNormal",
    ["SnacksPickerToggle"] = "TelescopeSelectionCaret",
    ["SnacksNormal"] = "TelescopeNormal",
    ["SnacksNormalNC"] = "TelescopeNormal",
    ["SnacksBackdrop"] = "TelescopeNormal",
    ["SnacksIndent"] = "TelescopeNormal",
    ["SnacksIndentChunk"] = "TelescopeNormal",
    ["SnacksIndentScope"] = "TelescopeNormal",
    ["SnacksIndent1"] = "TelescopeNormal",
    ["SnacksIndent2"] = "TelescopeNormal",
    ["SnacksIndent3"] = "TelescopeNormal",
    ["SnacksIndent4"] = "TelescopeNormal",
    ["SnacksIndent5"] = "TelescopeNormal",
    ["SnacksIndent6"] = "TelescopeNormal",
    ["SnacksIndent7"] = "TelescopeNormal",
    ["SnacksIndent8"] = "TelescopeNormal",
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
end

-- Set up autocmd to ensure it runs on VimEnter as well
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = M.setup_highlights,
})

return M
