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
    ["FzfLuaHeaderBind"] = "TelescopeResultsNumber",
    ["FzfLuaHeaderText"] = "TelescopeResultsComment",
    ["FzfLuaPathColNr"] = "TelescopeResultsNumber",
    ["FzfLuaPathLineNr"] = "TelescopeResultsLineNr",
    ["FzfLuaBufName"] = "TelescopeResultsIdentifier",
    ["FzfLuaBufId"] = "TelescopeResultsIdentifier",
    ["FzfLuaBufNr"] = "TelescopeResultsIdentifier",
    ["FzfLuaBufLineNr"] = "TelescopeResultsLineNr",
    ["FzfLuaBufFlagCur"] = "TelescopeResultsComment",
    ["FzfLuaBufFlagAlt"] = "TelescopeResultsComment",
    ["FzfLuaTabTitle"] = "TelescopePreviewTitle",
    ["FzfLuaTabMarker"] = "TelescopePreviewTitle",
    ["FzfLuaDirIcon"] = "TelescopePreviewDirectory",
    ["FzfLuaDirPart"] = "TelescopeResultsComment",
    ["FzfLuaFilePart"] = "TelescopeResultsComment",
    ["FzfLuaLiveSym"] = "TelescopeMatching",
    ["FzfLuaFzfNormal"] = "TelescopeNormal",
    ["FzfLuaFzfCursorLine"] = "TelescopeSelection",
    ["FzfLuaFzfMatch"] = "TelescopeMatching",
    ["FzfLuaFzfBorder"] = "TelescopeBorder",
    ["FzfLuaFzfScrollbar"] = "TelescopeBorder",
    ["FzfLuaFzfSeparator"] = "comment",
    ["FzfLuaFzfGutter"] = "TelescopeNormal",
    ["FzfLuaFzfHeader"] = "TelescopeResultsComment",
    ["FzfLuaFzfInfo"] = "Error",
    ["FzfLuaFzfPointer"] = "TelescopeSelectionCaret",
    ["FzfLuaFzfMarker"] = "TelescopeSelectionCaret",
    ["FzfLuaFzfSpinner"] = "TelescopeSelectionCaret",
    ["FzfLuaFzfPrompt"] = "TelescopePromptNormal",
    ["FzfLuaFzfQuery"] = "TelescopeMatching",
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

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = M.setup_highlights,
})

return M
