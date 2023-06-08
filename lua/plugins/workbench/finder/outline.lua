return {
  'simrat39/symbols-outline.nvim',
  keys = {
    { '<leader>/o', '<cmd>SymbolsOutline<cr>', desc = 'Symbols outline' }
  },
  cmd = { 'SymbolsOutline', 'SymbolsOutlineOpen', 'SymbolsOutlineClose' },
  opts = {
    -- https://github.com/simrat39/symbols-outline.nvim
    show_guides = true,
    auto_preview = false,
    autofold_depth = 2,
    width = 20,
    auto_close = true, -- auto close after selection
    keymaps = {
      close = { "<Esc>", "q", "Q", "<leader>x" },
    },
    lsp_blacklist = {
      "null-ls",
      "tailwindcss",
    },
  }
}
