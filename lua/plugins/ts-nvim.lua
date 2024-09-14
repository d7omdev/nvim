-- this file will hold ts stuff
return {
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    event = "VeryLazy",
    ft = { "typescript", "typescriptreact" },
    config = function()
      require("typescript-tools").setup({
        settings = {
          -- spawn additional tsserver instance to calculate diagnostics on it
          separate_diagnostic_server = true,
          -- "change"|"insert_leave" determine when the client asks the server about diagnostic
          publish_diagnostic_on = "insert_leave",
          -- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
          -- "remove_unused_imports"|"organize_imports") -- or string "all"
          -- to include all supported code actions
          -- specify commands exposed as code_actions
          -- not exists then standard path resolution strategy is applied
          tsserver_path = nil,
          -- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
          -- (see 💅 `styled-components` support section)
          tsserver_plugins = {},
          -- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
          -- memory limit in megabytes or "auto"(basically no limit)
          tsserver_max_memory = "3072",
          -- described below
          tsserver_format_options = {
            insertSpaceAfterCommaDelimiter = true,
            insertSpaceAfterSemicolonInForStatements = true,
            insertSpaceBeforeAndAfterBinaryOperators = true,
            insertSpaceAfterConstructor = true,
            insertSpaceAfterKeywordsInControlFlowStatements = true,
            insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
            insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = true,
            insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = true,
            insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = true,
            insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
            insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = true,
            insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = true,
            insertSpaceAfterTypeAssertion = true,
            insertSpaceBeforeFunctionParenthesis = true,
            placeOpenBraceOnNewLineForFunctions = false,
            placeOpenBraceOnNewLineForControlBlocks = false,
            insertSpaceBeforeTypeAnnotation = true,
            semicolons = "remove",
          },
          tsserver_file_preferences = {
            disableSuggestions = false,
            -- "auto" | "double" | "single"
            quotePreference = "auto",
            includeCompletionsForModuleExports = true,
            includeCompletionsForImportStatements = true,
            includeCompletionsWithSnippetText = true,
            includeCompletionsWithInsertText = true,
            includeAutomaticOptionalChainCompletions = true,
            includeCompletionsWithClassMemberSnippets = false,
            includeCompletionsWithObjectLiteralMethodSnippets = false,
            useLabelDetailsInCompletionEntries = false,
            allowIncompleteCompletions = false,
            -- "shortest" | "project-relative" | "relative" | "non-relative"
            importModuleSpecifierPreference = "shortest",
            -- "auto" | "minimal" | "index" | "js"
            importModuleSpecifierEnding = "auto",
            allowTextChangesInNewFiles = false,
            lazyConfiguredProjectsFromExternalProject = false,
            providePrefixAndSuffixTextForRename = false,
            provideRefactorNotApplicableReason = false,
            allowRenameOfImportPath = false,
            -- "auto" | "on" | "off"
            includePackageJsonAutoImports = "auto",
            -- "auto" | "braces" | "none"
            jsxAttributeCompletionStyle = "auto",
            displayPartsForJSDoc = false,
            generateReturnInDocTemplate = false,
            -- "none" | "literals" | "all"
            includeInlayParameterNameHints = "none",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = false,
            includeInlayVariableTypeHints = false,
            includeInlayVariableTypeHintsWhenTypeMatchesName = false,
            includeInlayPropertyDeclarationTypeHints = false,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayEnumMemberValueHints = false,
            -- array of strings
            autoImportFileExcludePatterns = {},
            -- "auto" | boolean
            organizeImportsIgnoreCase = "auto",
            -- "ordinal" | "unicode"
            organizeImportsCollation = "ordinal",
            -- string
            organizeImportsCollationLocale = "en",
            organizeImportsNumericCollation = false,
            organizeImportsAccentCollation = true,
            -- "upper" | "lower" | false
            organizeImportsCaseFirst = false,
            disableLineTextInReferences = false,
          },
          -- locale of all tsserver messages, supported locales you can find here:
          -- https://github.com/microsoft/TypeScript/blob/3c221fc086be52b19801f6e8d82596d04607ede6/src/compiler/utilitiesPublic.ts#L620
          tsserver_locale = "en",
          -- mirror of VSCode's `typescript.suggest.completeFunctionCalls`
          complete_function_calls = true,
          include_completions_with_insert_text = true,
          -- CodeLens
          -- WARNING: Experimental feature also in VSCode, because it might hit performance of server.
          -- possible values: ("off"|"all"|"implementations_only"|"references_only")
          code_lens = "off",
          -- by default code lenses are displayed on all referencable values and for some of you it can
          -- be too much this option reduce count of them by removing member references from lenses
          disable_member_code_lens = true,
          -- JSXCloseTag
          -- WARNING: it is disabled by default (maybe you configuration or distro already uses nvim-ts-autotag,
          -- that maybe have a conflict if enable this feature. )
          jsx_close_tag = {
            enable = false,
            filetypes = { "javascriptreact", "typescriptreact" },
          },
        },
      })
    end,
  },
  {
    "davidosomething/format-ts-errors.nvim",
    event = "VeryLazy",
  },
  {
    "OlegGulevskyy/better-ts-errors.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = {
      keymaps = {
        toggle = "<leader>dd", -- default '<leader>dd'
        go_to_definition = "<leader>dx", -- default '<leader>dx'
      },
    },
  },
  {
    "piersolenski/telescope-import.nvim",
    event = "VeryLazy",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function()
      require("telescope").load_extension("import")
    end,
  },
}
