local au = require('libs.runtime.au')
local plug = require('libs.runtime.pack').plug
local cmdstr = require('libs.runtime.keymap').cmdstr

plug({
  {
    -- 'anuvyklack/hydra.nvim',
    'pze/hydra.nvim',
    keys = {
      {
        '<C-w>',
        cmdstr([[lua require("libs.hydra.window").open_window_hydra(true)]]),
        desc = 'Window operations',
      }
    }
  },

  {
    'anuvyklack/windows.nvim',
    dependencies = {
      'anuvyklack/middleclass',
    },
    event = { 'WinLeave', 'WinNew' },
    opts = {
      ignore = {
        buftype = vim.cfg.misc__buf_exclude,
        filetype = vim.cfg.misc__ft_exclude,
      }
    },
    lazy = true,
    cmd = {
      'WindowsMaximize',
      'WindowsMaximizeVertically',
      'WindowsMaximizeHorizontally',
      'WindowsEqualize',
      'WindowsEnableAutowidth',
      'WindowsDisableAutowidth',
      'WindowsToggleAutowidth',
    },
  },

  {
    -- https://github.com/kevinhwang91/nvim-bqf
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    dependencies = {
      { 'junegunn/fzf', build = function() vim.fn['fzf#install']() end },
    },
  },

  ----- buffers
  {
    'kazhala/close-buffers.nvim',
    module = 'close_buffers',
    cmd = {
      'BDelete',
      'BWipeout',
    }
  },
  {
    'kwkarlwang/bufresize.nvim',
    event = 'WinResized',
    lazy = true,
    config = true,
  },

  {
    'echasnovski/mini.bufremove',
    keys = {
      {
        '<leader>bx',
        '<cmd>lua require("mini.bufremove").delete(0)<cr>',
        desc = 'Close current buffer',
      },
      {
        '<leader>bq',
        function()
          vim.cmd('q')
        end,
        desc = 'Close current buffer and window',
      },
      {
        '<S-q>',
        function()
          require('mini.bufremove').delete(0)
          -- vim.schedule(function()
          --   if #require('libs.runtime.buffer').list_bufnrs() <= 0 then
          --     local cur_empty = require('libs.runtime.buffer').get_current_empty_buffer()
          --     -- start_dashboard()
          --     if cur_empty then
          --       vim.api.nvim_buf_delete(cur_empty, { force = true })
          --     end
          --   end
          -- end)
        end,
        desc = 'Quit current buffer',
      }
    }
  },

  --- open buffer last place.
  {
    'ethanholz/nvim-lastplace',
    event = { 'BufReadPre', },
    opts = {
      lastplace_ignore_buftype = vim.cfg.misc__buf_exclude,
      lastplace_ignore_filetype = vim.cfg.misc__ft_exclude,
      lastplace_open_folds = true,
    }
  },

  --- auto close buffer after a time.
  {
    'chrisgrieser/nvim-early-retirement',
    enabled = false,
    config = function()
      require('early-retirement').setup({
        retirementAgeMins = 15,
        ignoreAltFile = true,
        minimumBufferNum = 10,
        ignoreUnsavedChangesBufs = true,
        ignoreSpecialBuftypes = true,
        ignoreVisibleBufs = true,
        ignoreUnloadedBufs = false,
        notificationOnAutoClose = true,
      })
    end,
    init = function()
      local loaded = false
      au.define_autocmds({
        {
          "User",
          {
            group = "_plugin_load_early_retirement",
            pattern = au.user_autocmds.FileOpened,
            once = true,
            callback = function()
              if loaded then
                return
              end
              loaded = true
              vim.defer_fn(function()
                vim.cmd("Lazy load nvim-early-retirement")
              end, 2000)
            end,
          }
        }
      })
    end,
  },

  ----- file
  {
    -- Convenience file operations for neovim, written in lua.
    "chrisgrieser/nvim-genghis",
    init = function()
      au.define_user_autocmd({
        pattern = au.user_autocmds.LegendaryConfigDone,
        callback = function()
          local lg = require('legendary')
          local genghis = require('genghis')

          lg.funcs({
            {
              description = 'File: Copy file path',
              genghis.copyFilepath,
            },
            {
              description = 'File: Change file mode',
              genghis.chmodx,
            },
            {
              description = 'File: Rename file',
              genghis.renameFile,
            },
            {
              description = 'File: Move and rename file',
              genghis.moveAndRenameFile,
            },
            {
              description = 'File: Create new file',
              genghis.createNewFile,
            },
            {
              description = 'File: Duplicate file',
              genghis.duplicateFile,
            },
            {
              description = 'File: Trash file',
              function()
                genghis.trashFile()
              end,
            },
            {
              description = 'File: Move selection to new file',
              genghis.moveSelectionToNewFile,
            }
          })
        end,
      })
    end
  },

  ----- grapple and portal
  {
    'cbochs/portal.nvim',
    cmd = { 'Portal' },
    keys = {
      {
        '<M-o>',
        function()
          local builtins = require('portal.builtin')
          local opts = {
            direction = 'backward',
            max_results = 2,
          }

          local jumplist = builtins.jumplist.query(opts)
          -- local harpoon = builtins.harpoon.query(opts)
          local grapples = builtins.grapple.query(opts)

          require('portal').tunnel({ jumplist, grapples })
        end,
        desc = 'Portal jump backward',
      },
      {
        '<M-i>',
        function()
          local builtins = require('portal.builtin')
          local opts = {
            direction = 'forward',
            max_results = 2,
          }

          local jumplist = builtins.jumplist.query(opts)
          -- local harpoon = builtins.harpoon.query(opts)
          local grapples = builtins.grapple.query(opts)

          require('portal').tunnel({ jumplist, grapples })
        end,
        desc = 'Portal jump forward',
      }
    },
    dependencies = {
      'cbochs/grapple.nvim',
    },
    config = function()
      -- local nvim_set_hl = vim.api.nvim_set_hl
      require('portal').setup({
        log_level = 'error',
        window_options = {
          relative = "cursor",
          width = 40,
          height = 2,
          col = 1,
          focusable = false,
          border = "rounded",
          noautocmd = true,
        }
      })

      -- FIXME: colors.
      -- nvim_set_hl(0, 'PortalBorderForward', { fg = colors.portal_border_forward })
      -- nvim_set_hl(0, 'PortalBorderNone', { fg = colors.portal_border_none })
    end,
  },
  {
    'cbochs/grapple.nvim',
    keys = {
      { '<leader>bg', '<cmd>GrappleToggle<cr>', desc = 'Toggle grapple' },
      { '<leader>bp', '<cmd>GrapplePopup<cr>',  desc = 'Popup grapple' },
      { '<leader>bc', '<cmd>GrappleCycle<cr>',  desc = 'Cycle grapple' },
    },
    cmd = { 'GrappleToggle', 'GrapplePopup', 'GrappleCycle' },
    opts = {
      log_level = 'error',
      scope = 'git',
      integrations = {
        resession = false,
      },
    }
  },
  ---- monorepo
  {
    "imNel/monorepo.nvim",
    keys = {
      {
        '<leader>em',
        [[<cmd>lua require("telescope").extensions.monorepo.monorepo()<cr>]],
        desc = 'Manage monorepo',
      },
      {
        '<leader>e$',
        [[<cmd>lua require("monorepo").toggle_project()<cr>]],
        desc = 'Toggle cwd as project'
      },
    },
    opts = {
      autoload_telescope = true,
    }
  },

  {
    'telescope.nvim',
    dependencies = {
      {
        'ahmedkhalf/project.nvim',
        name = 'project_nvim',
        cmd = { 'ProjectRoot' },
        keys = {
          {
            '<leader>ep', '<Cmd>Telescope projects<CR>', desc = 'Projects',
          }
        },
        config = function(_, opts)
          require('project_nvim').setup(opts)
          require('telescope').load_extension('projects')
        end,
        opts = {
          patterns = { '.git', '_darcs', '.bzr', '.svn', '.vscode', '.gitmodules', 'pnpm-workspace.yaml' },
          manual_mode = false,
          -- Table of lsp clients to ignore by name
          -- eg: { "efm", ... }
          ignore_lsp = {},
          -- Don't calculate root dir on specific directories
          -- Ex: { "~/.cargo/*", ... }
          exclude_dirs = {},
          -- Show hidden files in telescope
          show_hidden = false,
          -- When set to false, you will get a message when project.nvim changes your
          -- directory.
          silent_chdir = true,
          -- What scope to change the directory, valid options are
          -- * global (default)
          -- * tab
          -- * win
          scope_chdir = 'global',
        }
      }
    }
  },
  {
    "goolord/alpha-nvim",
    optional = true,
    opts = function(_, dashboard)
      local button = dashboard.button("p", " " .. " Projects", ":Telescope projects <CR>")
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
      table.insert(dashboard.section.buttons.val, 4, button)
    end
  },
  {
    "echasnovski/mini.starter",
    optional = true,
    opts = function(_, opts)
      local items = {
        {
          name = "Projects",
          action = "Telescope projects",
          section = string.rep(" ", 0) .. "Telescope",
        },
      }
      vim.list_extend(opts.items, items)
    end,
  },

  {
    'Shatur/neovim-session-manager',
    cmd = { 'SessionManager' },
    keys = {
      {
        '<leader>/s',
        '<cmd>SessionManager load_current_dir_session<CR>',
        desc = 'Load current session',
      }
    },
    config = function()
      local session_manager = require('session_manager')
      local Path = require('plenary.path')

      session_manager.setup({
        sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),             -- The directory where the session files will be saved.
        path_replacer = '__',                                                    -- The character to which the path separator will be replaced for session files.
        colon_replacer = '++',                                                   -- The character to which the colon symbol will be replaced for session files.
        autoload_mode = require('session_manager.config').AutoloadMode.Disabled, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
        autosave_last_session = true,                                            -- Automatically save last session on exit and on session switch.
        autosave_ignore_not_normal = true,                                       -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
        autosave_ignore_filetypes = vim.tbl_extend('force',
          {                                                                      -- All buffers of these file types will be closed before the session is saved.
            'gitcommit',
            'toggleterm',
            'term',
            'nvimtree'
          }, vim.cfg.misc__ft_exclude),
        autosave_only_in_session = true, -- Always autosaves session. If true, only autosaves after a session is active.
        max_path_length = 80,            -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
      })
    end,
  },

  {
    'kwkarlwang/bufresize.nvim',
    config = true,
  },
  {
    'mrjones2014/smart-splits.nvim',
    keys = {
      { '<A-h>', cmdstr([[lua require("smart-splits").resize_left()]]),       desc = 'Resize window to left' },
      { '<A-j>', cmdstr([[lua require("smart-splits").resize_down()]]),       desc = 'Resize window to down' },
      { '<A-k>', cmdstr([[lua require("smart-splits").resize_up()]]),         desc = 'Resize window to up' },
      { '<A-l>', cmdstr([[lua require("smart-splits").resize_right()]]),      desc = 'Resize window to right' },
      { '<C-h>', cmdstr([[lua require("smart-splits").move_cursor_left()]]),  desc = 'Move cursor to left window' },
      { '<C-j>', cmdstr([[lua require("smart-splits").move_cursor_down()]]),  desc = 'Move cursor to down window' },
      { '<C-k>', cmdstr([[lua require("smart-splits").move_cursor_up()]]),    desc = 'Move cursor to up window' },
      { '<C-l>', cmdstr([[lua require("smart-splits").move_cursor_right()]]), desc = 'Move cursor to right window' },
    },
    dependencies = {
      'kwkarlwang/bufresize.nvim',
    },
    build = "./kitty/install-kittens.bash",
    config = function()
      local splits = require("smart-splits")

      splits.setup({
        -- Ignored filetypes (only while resizing)
        ignored_filetypes = {
          'nofile',
          'quickfix',
          'prompt',
          'qf',
        },
        -- Ignored buffer types (only while resizing)
        ignored_buftypes = { 'nofile', 'NvimTree', },
        resize_mode = {
          quit_key = {
            quit_key = '<ESC>',
            resize_keys = { 'h', 'j', 'k', 'l' },
          },
          hooks = {
            on_leave = function() require('bufresize').register() end,
          },
        },
        ignored_events = {
          'BufEnter',
          'WinEnter',
        },
        log_level = "error",
        disable_multiplexer_nav_when_zoomed = true,
      })
    end,
  },

  {
    'folke/trouble.nvim',
    cmd = { 'TroubleToggle', 'Trouble' },
    keys = {
      {
        '<leader>cd', '<cmd>TroubleToggle document_diagnostics<cr>', desc = 'Toggle document diagnostics'
      },
      {
        '<leader>wd', '<cmd>TroubleToggle workspace_diagnostics<cr>', desc = 'Toggle workspace diagnostics'
      },
      {
        '<leader>tq',
        function()
          if require('trouble').is_open() then
            require('trouble').close()
            return
          end
          local buffers = vim.api.nvim_list_bufs()
          local bufFound = false
          for _, buffer in ipairs(buffers) do
            local bufferType = vim.api.nvim_buf_get_option(buffer, 'buftype')
            if bufferType == 'quickfix' then
              bufFound = true
              break
            end
          end
          if not bufFound then
            vim.api.nvim_command('botright copen 10')
          else
            vim.api.nvim_command('cclose')
          end
        end,
        desc = 'Quick list'
      }
    },
    config = function()
      local icons = require('libs.icons')
      require('trouble').setup({
        position = 'bottom',           -- position of the list can be: bottom, top, left, right
        height = 10,                   -- height of the trouble list when position is top or bottom
        width = 50,                    -- width of the list when position is left or right
        icons = true,                  -- use devicons for filenames
        mode = 'document_diagnostics', -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
        fold_open = '',             -- icon used for open folds
        fold_closed = '',           -- icon used for closed folds
        group = true,                  -- group results by file
        padding = true,                -- add an extra new line on top of the list
        action_keys = {
          -- key mappings for actions in the trouble list
          -- map to {} to remove a mapping, for example:
          -- close = {},
          close = 'q',                     -- close the list
          cancel = '<esc>',                -- cancel the preview and get back to your last window / buffer / cursor
          refresh = 'r',                   -- manually refresh
          jump = { '<cr>', '<tab>' },      -- jump to the diagnostic or open / close folds
          open_split = { '<c-x>' },        -- open buffer in new split
          open_vsplit = { '<c-v>' },       -- open buffer in new vsplit
          open_tab = { '<c-t>' },          -- open buffer in new tab
          jump_close = { 'o' },            -- jump to the diagnostic and close the list
          toggle_mode = 'm',               -- toggle between "workspace" and "document" diagnostics mode
          toggle_preview = 'P',            -- toggle auto_preview
          hover = 'K',                     -- opens a small popup with the full multiline message
          preview = 'p',                   -- preview the diagnostic location
          close_folds = { 'zM', 'zm' },    -- close all folds
          open_folds = { 'zR', 'zr' },     -- open all folds
          toggle_fold = { 'zA', 'za' },    -- toggle fold of current file
          previous = 'k',                  -- preview item
          next = 'j',                      -- next item
        },
        indent_lines = true,               -- add an indent guide below the fold icons
        auto_open = false,                 -- automatically open the list when you have diagnostics
        auto_close = false,                -- automatically close the list when you have no diagnostics
        auto_preview = true,               -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
        auto_fold = false,                 -- automatically fold a file trouble list at creation
        auto_jump = { 'lsp_definitions' }, -- for the given modes, automatically jump if there is only a single result
        signs = {
          -- icons / text used for a diagnostic
          error = icons.errorOutline,
          warning = icons.warningTriangleNoBg,
          hint = icons.lightbulbOutline,
          information = icons.infoOutline,
        },
        use_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
      })
    end,
    init = function()
      au.define_user_autocmd({
        group = "setup_trouble_lg",
        pattern = au.user_autocmds.LegendaryConfigDone,
        once = true,
        callback = function()
          local lg = require('legendary')
          lg.commands({
            -- troubles.
            {
              ':TodoTrouble',
              description = 'Show todo in trouble',
            },
            {
              [[:exe "TodoTrouble cwd=" . expand("%:p:h")]],
              description = 'Show todo in trouble within current file directory',
            },
          })
        end,
      })
    end,
  },

  {
    's1n7ax/nvim-window-picker',
    opts = {
      autoselect_one = true,
      selection_chars = "ABCDEFGHIJKLMNOPQRSTUVW"
    }
  }
})
