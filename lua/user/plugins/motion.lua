local plug = require('userlib.runtime.pack').plug
local cmd = require('userlib.runtime.keymap').cmdstr
local au = require('userlib.runtime.au')

plug({
  {
    -- jump html tags.
    'harrisoncramer/jump-tag',
    vscode = true,
    keys = {
      {
        '[tp',
        cmd([[lua require('jump-tag').jumpParent()]]),
        desc = 'Jump to parent tag',
      },
      {
        '[tc',
        cmd([[lua require('jump-tag').jumpChild()]]),
        desc = 'Jump to child tag',
      },
      {
        '[t]',
        cmd([[lua require('jump-tag').jumpNextSibling()]]),
        desc = 'Jump to next tag',
      },
      {
        '[t[',
        cmd([[lua require('jump-tag').jumpPrevSibling()]]),
        desc = 'Jump to prev tag',
      },
    },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
  },
  {
    'pze/mini.ai',
    vscode = true,
    -- disabled due to not compatible with nvim-treesitter#1.0
    enabled = true,
    dev = false,
    -- event = au.user_autocmds.FileOpenedAfter_User,
    event = { 'CursorHold' },
    opts = function()
      local ai = require('mini.ai')
      return {
        search_method = 'cover_or_nearest',
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          }, {
            use_nvim_treesitter = false,
          }),
          f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }, {
            use_nvim_treesitter = false,
          }),
          c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }, {
            use_nvim_treesitter = false
          }),
        },
      }
    end,
    config = function(_, opts)
      require('mini.ai').setup(opts)
    end,
  },

  {
    'kylechui/nvim-surround',
    vscode = true,
    version = '*',
    event = au.user_autocmds.FileOpened_User,
    opts = {
      keymaps = {
        delete = 'dz',
      },
    },
  },

  {
    -- https://github.com/Wansmer/treesj
    'Wansmer/treesj',
    vscode = true,
    keys = {
      {
        '<leader>mjt',
        '<cmd>lua require("treesj").toggle()<cr>',
        desc = 'Toggle',
      },
      {
        '<leader>mjs',
        '<cmd>lua require("treesj").split()<cr>',
        desc = 'Split',
      },
      {
        '<leader>mjj',
        '<cmd>lua require("treesj").join()<cr>',
        desc = 'Join',
      },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      use_default_keymaps = false,
    },
  },
  ---prevent the cursor from moving when using shift and filter actions.
  { 'gbprod/stay-in-place.nvim', config = true, event = au.user_autocmds.FileOpenedAfter_User },

  {
    'folke/flash.nvim',
    vscode = true,
    event = 'User LazyUIEnterOncePost',
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function() require('flash').jump() end,
        desc = 'Flash',
      },
      {
        '<C-s>',
        mode = { 'n' },
        function()
          require('flash').jump({
            search = { mode = 'search', max_length = 0 },
            label = { after = { 0, 0 } },
            pattern = '\\(^\\s*\\)\\@<=\\S',
          })
        end,
        desc = 'Flash jump to line',
      },
      {
        '.s',
        mode = { 'n', 'x', 'o' },
        function() require('flash').treesitter() end,
        desc = 'Flash treesitter',
      },
      {
        'r',
        mode = 'o',
        function() require('flash').remote() end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function() require('flash').treesitter_search() end,
        desc = 'Treesitter Search',
      },
    },
    opts = {
      search = {
        exclude = vim.cfg.misc__ft_exclude,
      },
      modes = {
        -- options used when flash is activated through
        -- a regular search with `/` or `?`
        search = {
          enabled = false,
        },
      },
    },
    config = function(_, opts) require('flash').setup(opts) end,
  },
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
    --- see https://github.com/folke/flash.nvim#%EF%B8%8F-configuration
    opts = function(_, opts)
      local function flash(prompt_bufnr)
        require('flash').jump({
          pattern = '^',
          label = {
            after = { 0, 0 },
          },
          highlight = {
            backdrop = true,
          },
          search = {
            mode = 'search',
            exclude = {
              function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'TelescopeResults' end,
            },
          },
          action = function(match)
            local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end

      opts.defaults = vim.tbl_deep_extend('force', opts.defaults or {}, {
        mappings = {
          n = { ['-'] = flash },
          i = { ['<c-->'] = flash },
        },
      })
    end,
  },

  {
    --- Readline keybindings,
    --- C-e, C-f, etc.
    'tpope/vim-rsi',
    vscode = true,
    event = {
      'InsertEnter',
      'CmdlineEnter',
    },
  },
})
