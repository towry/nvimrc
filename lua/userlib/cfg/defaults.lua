local cwd = vim.uv.cwd()

return {
  ---runtime
  runtime__folder_holes_inregex = {
    'node_modules/',
    '.git/',
    '.turbo/',
    'dist/',
    '.cargo/',
  },
  runtime__starts_in_buffer = vim.fn.argc(-1) ~= 0,
  runtime__starts_cwd = cwd,
  runtime__starts_cwd_short = require('userlib.runtime.path').home_to_tilde(cwd),
  runtime__disable_builtin_plugins = {
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "matchit",
    "matchparen",
    "logiPat",
    "rust_vim",
    "rust_vim_plugin_cargo",
    "rrhelper",
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
  },
  runtime__disable_builtin_provider = {
    "perl",
    "node",
    "ruby",
    "python",
    "python3",
  },
  runtime__python3_host_prog = '$HOME/.pyenv/shims/python',
  ---editor stuff
  --enable relative number or not.
  editor__relative_number = true,
  editor__highlight_yanked = true,
  editor__terminal_auto_insert = true,
  editor__jump_lastline_enable = true,
  editor__jump_lastline_ignore_filetypes = { "gitcommit", "gitrebase", "svn", "hgcommit", "Dashboard" },
  editor__jump_lastline_ignore_buftypes = { "quickfix", "nofile", "help" },
  -- editor extended features.
  editorExtend__colorizer_enable = true,
  editorExtend__colorizer_filetypes = {
    'html',
    'css',
    'javascript',
    'typescript',
    'typescriptreact',
    'javascriptreact',
    'lua',
    'sass',
    'scss',
    'less',
  },
  editorExtend__colorizer_enable_tailwind_color = true,
  ---languages
  ---- must installed, otherwise slowness.
  lang__treesitter_ensure_installed = {
    'comment',
    'diff',
    'vim',
    'vimdoc',
    'bash',
    'css',
    'html',
    'javascript',
    'json',
    'jsonc',
    'jsdoc',
    'lua',
    'python',
    'regex',
    'rust',
    'scss',
    'tsx',
    'typescript',
    'yaml',
    'markdown',
    'markdown_inline',
  },
  lang__treesitter_plugin_disable_on_filetypes = {
    "NvimTree",
    "starter",
    "git",
  },
  lang__treesitter_plugin_incremental_selection = true,
  lang__treesitter_plugin_highlight = true,
  lang__treesitter_plugin_indent = true,
  lang__treesitter_plugin_yati = true,
  lang__treesitter_plugin_rainbow = false,
  lang__treesitter_plugin_context_commentstring = true,
  lang__treesitter_plugin_refactor = true,
  lang__treesitter_plugin_textobjects_move = true,
  lang__treesitter_plugin_textsubjects = true,
  lsp__log_level = "INFO",
  lsp__enable_servers = {
    "tailwindcss",
    "cssls",
    "jsonls",
    "lua_ls",
    "volar",
    "bashls",
    "html",
    -- "tsserver",
    "null_ls"
  },
  lsp__auto_install_servers = {
    'bashls',
    'cssls',
    'eslint',
    'html',
    'jsonls',
    'lua_ls',
    'tailwindcss',
    'tsserver',
    'volar',
    'prismals',
  },
  lsp__automatic_installation = true,
  lsp__server_tailwindcss_prettier = false,
  lsp__server_volar_takeover_mode = true,
  lsp__ui_progress = true,
  lsp__ui_progress_ignore_servers = {
    "null-ls",
    "tailwindcss",
  },
  lsp__allow_incremental_sync = false,
  lsp__debounce_text_changes = 600,
  lsp__format_on_save = true,
  lsp__format_on_save_on_filetypes = {
    'vue',
    'typescript',
    'typescriptreact',
    'javascriptreact',
    'javascript',
    'css',
    'lua',
    'html',
    'scss',
  },
  lsp__plugin_lspsaga = true,
  ---User interfaces
  ui__theme_name = "default",
  ui__float_border = 'single',
  workbench__lualine_theme = "default",
  ---misc stuff.
  misc__buf_exclude = {
    "netrw",
    "tutor",
    'quickfix',
    'nofile',
    'help',
    'prompt',
    "terminal",
    "nowrite",
  },
  misc__ft_exclude = {
    "diff",
    "alpha",
    "starter",
    "lazy",
    "TelescopePrompt",
    "toggleterm",
    "nofile",
    "spectre_panel",
    "help",
    "txt",
    "log",
    "Trouble",
    "NvimTree",
    "qf",
    "harpoon",
    "Outline",
    "fugitive",
    "fugitiveblame",
    "Git",
    "undotree",
    -- folke/noice
    "noice",
  },
  ---plugins specific.
}
