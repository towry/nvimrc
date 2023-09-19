local user_cfg = {
  ui__theme_name = 'slate',
  workbench__lualine_theme = 'auto',
  --- treesitter
  lang__treesitter_plugin_rainbow = false,
  plug__enable_codeium_vim = true,
}

return {
  setup = function() require('userlib.cfg').setup(user_cfg) end,
}
