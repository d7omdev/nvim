return {
  "monkoose/neocodeium",
  event = "VeryLazy",
  config = function()
    local neocodeium = require("neocodeium")

    neocodeium.setup({
      enabled = true,
      manual = false,
      debounce = true, -- Enable debouncing to prevent slow typing
      show_label = true,
      filetypes = {
        help = false,
        gitcommit = false,
        gitrebase = false,
        ["."] = false,
      },
    })

    -- Accept suggestion with Tab (Neocodeium takes priority)
    vim.keymap.set("i", "<Tab>", function()
      -- If neocodeium has a suggestion, accept it first
      if neocodeium.visible() then
        neocodeium.accept()
        return
      end
      -- Otherwise check blink menu
      local blink_ok, blink = pcall(require, "blink.cmp")
      if blink_ok and blink.is_visible() then
        return blink.select_and_accept()
      end
      -- Fallback to normal tab
      return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
    end, { expr = true, silent = true })

    -- Clear on Esc (don't block it)
    vim.keymap.set("i", "<Esc>", function()
      if neocodeium.visible() then
        neocodeium.clear()
      end
      -- Always send Esc
      vim.cmd("stopinsert")
    end, { silent = true })

    -- Accept word
    vim.keymap.set("i", "<C-l>", function()
      require("neocodeium").accept_word()
    end, { desc = "NeoCodeium: Accept word" })

    -- Accept line
    vim.keymap.set("i", "<C-j>", function()
      require("neocodeium").accept_line()
    end, { desc = "NeoCodeium: Accept line" })

    -- Cycle to next suggestion
    vim.keymap.set("i", "<M-]>", function()
      require("neocodeium").cycle_or_complete()
    end, { desc = "NeoCodeium: Next suggestion" })

    vim.keymap.set("i", "<M-[>", function()
      require("neocodeium").cycle_or_complete(-1)
    end, { desc = "NeoCodeium: Previous suggestion" })

    -- Clear suggestion
    vim.keymap.set("i", "<C-x>", function()
      require("neocodeium").clear()
    end, { desc = "NeoCodeium: Clear suggestion" })
  end,
}
