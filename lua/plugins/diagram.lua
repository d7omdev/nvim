-- diagram.nvim — render Mermaid/D2/PlantUML/Gnuplot code blocks as images.
-- Hard-requires 3rd/image.nvim (it cannot use snacks.image).
--
-- Coexistence note: snacks.image stays the backend for normal markdown images.
-- image.nvim is added ONLY as a render surface for diagram.nvim, so its own
-- integrations are disabled to avoid both backends painting the same images.
--
-- External CLIs (per renderer): mermaid -> mmdc (installed), d2 -> d2,
-- plantuml -> plantuml, gnuplot -> gnuplot. Missing CLIs just no-op their type.
return {
  {
    "3rd/image.nvim",
    -- We're inside kitty (KITTY_WINDOW_ID set) under tmux. Kitty backend +
    -- tmux passthrough is what makes graphics survive the tmux layer.
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      -- Disabled: snacks.image owns markdown image rendering. Leaving these on
      -- would double-render and clash over placements.
      integrations = {},
      tmux_show_only_in_active_window = true,
    },
  },
  {
    "3rd/diagram.nvim",
    dependencies = { "3rd/image.nvim" },
    ft = { "markdown", "norg" },
    -- opts MUST be a function: the integration modules aren't on runtimepath
    -- until lazy loads the plugin, so requiring them in a literal table errors.
    opts = function()
      return {
        integrations = {
          require("diagram.integrations.markdown"),
        },
        renderer_options = {
          mermaid = {
            theme = "dark",
            background = "transparent", -- nil | "transparent" | "white" | "#hex"
            -- npm @mermaid-js/mermaid-cli (bun install -g @mermaid-js/mermaid-cli)
            -- drives Chromium via Puppeteer. We point it at the system Chrome
            -- and pass --no-sandbox through a puppeteer config file (the only
            -- way mmdc forwards browser args — it rejects --no-sandbox directly).
            cli_args = { "-p", vim.fn.expand("~/.config/nvim/puppeteer-config.json") },
          },
        },
      }
    end,
  },
}
