local M = {}

vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#6F737B", bg = Snacks.util.color("Normal", "bg") })
-- vim.api.nvim_set_hl(0, "SnacksPickerInputBorder", { fg = "#6F737B", bg = "#252931" })

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
end

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = M.setup_highlights,
})
-- ========================
-- Custom highlights
-- ========================

function M.set_hl(group, fg, bg, opts)
  opts = opts or {}
  opts.fg = fg
  opts.bg = bg
  vim.api.nvim_set_hl(0, group, opts)
end

M.statusline_bg = Snacks.util.color("StatusLine", "bg")
M.emptyspace_bg = Snacks.util.color("St_EmptySpace", "bg")

M.highlights = {
  St_macro_recording = { fg = "#CA6169", bg = M.statusline_bg, opts = { bold = true } },
  Updates = { fg = "#56B6C2", bg = M.emptyspace_bg },
  St_Updates_Icon = { fg = M.statusline_bg, bg = "#56B6C2" },
  St_Updates_sep = { fg = "#56B6C2", bg = M.statusline_bg },
}

function M.apply_highlights()
  for group, hl in pairs(M.highlights) do
    M.set_hl(group, hl.fg, hl.bg, hl.opts)
  end
end

M.apply_highlights()

return M
