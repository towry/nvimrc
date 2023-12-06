local plug = require('userlib.runtime.pack').plug

plug({
  'daschw/leaf.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  lazy = not string.match(vim.cfg.ui__theme_name, 'leaf'),
  enabled = vim.cfg.ui__theme_name == 'leaf',
  opts = {},
})
