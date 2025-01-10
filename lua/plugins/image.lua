package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"

return {
  {
    "3rd/image.nvim",
    enabled = not vim.g.neovide,
    event = "BufRead",
    ft = { "md" },
    config = function()
      require("image").setup({
        backend = "kitty",
        kitty_method = "normal",
        lua_version = "5.4",
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = true,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "vimwiki" },
          },
          neorg = {
            enabled = true,
            clear_in_insert_mode = true,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "norg" },
          },
          html = {
            enabled = true,
          },
          css = {
            enabled = true,
          },
        },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 40,
        window_overlap_clear_enabled = false,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        editor_only_render_when_focused = true,
        tmux_show_only_in_active_window = true,
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.webp", "*.avif" },
      })
    end,
  },
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        use_absolute_path = false, ---@type boolean
        relative_to_current_file = true, ---@type boolean
        dir_path = function()
          return vim.fn.expand("%:t:r") .. "-img"
        end,
        prompt_for_file_name = false, ---@type boolean
        file_name = "%Y-%m-%d-at-%H-%M-%S", ---@type string
        process_cmd = "convert - -quality 75 -resize 50% png:-", ---@type string
      },
      filetypes = {
        markdown = {
          url_encode_path = true, ---@type boolean
          template = "![$FILE_NAME]($FILE_PATH)", ---@type string
        },
      },
    },
    keys = {
      { "<leader>v", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },
}
