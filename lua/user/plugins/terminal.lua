local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')
local libutils = require('userlib.runtime.utils')

plug({
  {
    'akinsho/toggleterm.nvim',
    dev = false,
    keys = {
      {
        '<leader>gv',
        '<cmd>lua require("userlib.terminal.gitu").toggle()<cr>',
        desc = 'Gitu',
      },
      -- {
      --   '<leader>gv',
      --   '<cmd>lua require("userlib.terminal.term-git").toggle_tig()<cr>',
      --   desc = 'Tig commits',
      -- },
      {
        '<leader>gV',
        '<cmd>lua require("userlib.terminal.term-git").toggle_tig_file_history()<cr>',
        desc = 'Tig current file history',
      },
      {
        '<leader>rT',
        function()
          local input = vim.fn.input('TermExec(G): ', '', 'shellcmd')
          input = vim.trim(input or '')
          if input == '' then
            return
          end
          local cwd = vim.cfg.runtime__starts_cwd

          local cmd = ([[TermExec cmd='%s' dir='%s']]):format(input, cwd)
          vim.api.nvim_command(cmd)
        end,
        desc = 'TermExec command in starts cwd',
      },
      {
        '<leader>rt',
        function()
          local cwd = vim.uv.cwd()
          local cwd_short = vim.fn.fnamemodify(cwd or '', ':t')
          local input = vim.fn.input(string.format('TermExec(%s): ', cwd_short), '', 'shellcmd')
          input = vim.trim(input or '')
          if input == '' then
            return
          end

          local cmd = ([[TermExec cmd='%s' dir='%s']]):format(input, cwd)
          vim.api.nvim_command(cmd)
        end,
        desc = 'TermExec command',
      },
    },
    cmd = { 'ToggleTerm', 'TermExec' },
    branch = 'main',
    -- tag = 'v2.2.1',
    config = function()
      -- local au = require('userlib.runtime.au')
      local highlights = require('user.config.theme').toggleterm()

      require('toggleterm').setup({
        -- size can be a number or function which is passed the current terminal
        size = function(term)
          if term.direction == 'horizontal' then
            return 15
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
          end
        end,
        -- f24 = shift + f12
        open_mapping = nil,
        hide_numbers = true, -- hide the number column in toggleterm buffers
        -- this can affect fzf-lua terminal.
        highlights = highlights,
        --- this option cause fzf-lua hi not working properly
        -- shade_filetypes = { 'none', 'fzf' },
        shade_terminals = true,
        shading_factor = 1, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        persist_size = false,
        persist_mode = false,
        auto_scroll = true,
        direction = 'horizontal', -- | 'horizontal' | 'window' | 'float',
        close_on_exit = true, -- close the terminal window when the process exits
        shell = vim.o.shell, -- change the default shell
        -- This field is only relevant if direction is set to 'float'
        float_opts = {
          -- The border key is *almost* the same as 'nvim_win_open'
          -- see :h nvim_win_open for details on borders however
          -- the 'curved' border is a custom border type
          -- not natively supported but implemented in this plugin.
          border = vim.cfg.ui__float_border, -- single/double/shadow/curved
          winblend = 15,
        },
        winbar = {
          enabled = false,
        },
        on_close = function()
          vim.schedule(function()
            if vim.g.cmd_on_toggleterm_close ~= nil then
              vim.cmd(vim.g.cmd_on_toggleterm_close)
              vim.g.cmd_on_toggleterm_close = nil
            end
          end)
        end,
        on_open = vim.schedule_wrap(function(term)
          au.do_useraucmd(au.user_autocmds.TermIsOpen_User)
          vim.cmd('startinsert!')
          if vim.fn.exists('&winfixbuf') == 1 then
            vim.cmd('setlocal winfixbuf')
          end
        end),
      })
    end,
    init = function()
      local nvim_buf_set_keymap = vim.keymap.set
      _G._plugin_toggle_term = function(direction, vcount)
        vcount = vcount or 0
        local command = vcount .. 'ToggleTerm'
        if direction ~= nil then
          command = command .. ' direction=' .. direction
        end
        if vim.bo.filetype == 'toggleterm' then
          Ty.resize.block()
          vim.api.nvim_command(command)
          Ty.resize.after_close()
        else
          Ty.resize.block()
          vim.api.nvim_command(command)
          Ty.resize.after_open()
          vim.cmd([[execute "normal! i"]])
        end
      end
      _G._plugin_set_terminal_keymaps = vim.schedule_wrap(function()
        if vim.bo.filetype == 'fzf' then
          return
        end
        local Terminal = require('toggleterm.terminal')

        local buffer = vim.api.nvim_get_current_buf()
        local _, current_term = Terminal.identify()
        if not current_term then
          return
        end
        -- local current_term_is_hidden = current_term.hidden
        local opts = { noremap = true, buffer = buffer, nowait = true }
        nvim_buf_set_keymap('t', '<C-\\><C-\\>', [[<C-\><C-n>:call v:lua._plugin_toggle_term()<CR>]], opts)
      end)

      vim.cmd('autocmd! TermOpen term://* lua _plugin_set_terminal_keymaps()')
      --- open in project root.
      local misc_fts = {
        'NvimTree',
        'lazy',
        'fzf',
        'aerial',
      }
      vim.keymap.set('n', '<C-\\><C-\\>', function()
        if vim.tbl_contains(misc_fts, vim.bo.filetype) then
          vim.notify('please open in normal buffer')
          return
        end
        if vim.v.count == 9 then
          vim.cmd([[call v:lua._plugin_toggle_term('float', 9)]])
        else
          vim.cmd([[call v:lua._plugin_toggle_term('horizontal', ]] .. vim.v.count .. ')')
        end
      end, {
        desc = 'toggle term',
        silent = true,
      })

      vim.api.nvim_create_user_command('LocalTermExec', function(opts)
        local args = opts.args

        local cmd = ([[call v:lua.Ty.resize.block() <bar> TermExec cmd='%s' dir='%s' <bar> call v:lua.Ty.resize.after_open()]]):format(
          args,
          vim.uv.cwd()
        )
        vim.api.nvim_command(cmd)
      end, {
        nargs = '+',
        desc = 'Run TermExec in local cwd',
        complete = 'shellcmd',
      })
      vim.api.nvim_create_user_command('RootTermExec', function(opts)
        local args = opts.args

        local cmd = ([[call v:lua.Ty.resize.block() <bar> TermExec cmd='%s' dir='%s' <bar> call v:lua.Ty.resize.after_open()]]):format(
          args,
          vim.cfg.runtime__starts_cwd
        )
        vim.api.nvim_command(cmd)
      end, {
        nargs = '+',
        desc = 'Run TermExec in root cwd',
        complete = 'shellcmd',
      })
    end,
  },

  {
    'willothy/flatten.nvim',
    ft = { 'toggleterm', 'terminal', 'neo-term' },
    branch = 'guest-data',
    enabled = true,
    lazy = vim.env['NVIM'] == nil,
    priority = 1000,
    dependencies = {
      {
        'willothy/wezterm.nvim',
        opts = {},
      },
    },
    opts = function()
      local saved_terminal
      return {
        callbacks = {
          pipe_path = function()
            -- If running in a terminal inside Neovim:
            local nvim = vim.env.NVIM
            if nvim then
              return nvim
            end

            -- If running in a Wezterm terminal,
            -- all tabs/windows/os-windows in the same instance of wezterm will open in the first neovim instance
            local wezterm = vim.env.WEZTERM_UNIX_SOCKET
            if not wezterm then
              return
            end

            local addr = ('%s/%s'):format(
              vim.fn.stdpath('run'),
              'wezterm.nvim-' .. wezterm:match('gui%-sock%-(%d+)') .. '-' .. vim.fn.getcwd(-1):gsub('/', '_')
            )
            if not vim.loop.fs_stat(addr) then
              vim.fn.serverstart(addr)
            end

            return addr
          end,
          guest_data = function()
            if not vim.cfg.runtime__is_wezterm then
              return {}
            end
            return {
              pane = require('wezterm').get_current_pane(),
            }
          end,
          should_block = function(argv)
            -- Note that argv contains all the parts of the CLI command, including
            -- Neovim's path, commands, options and files.
            -- See: :help v:argv

            -- In this case, we would block if we find the `-b` flag
            -- This allows you to use `nvim -b file1` instead of `nvim --cmd 'let g:flatten_wait=1' file1`
            return vim.tbl_contains(argv, '-b') or vim.tbl_contains(argv, '-d') or vim.cfg.runtime__starts_as_gittool
          end,
          pre_open = function()
            if libutils.has_plugin('toggleterm.nvim') then
              local term = require('toggleterm.terminal')
              local termid = term.get_focused_id()
              saved_terminal = term.get(termid)
            end
          end,
          no_files = vim.cfg.runtime__is_wezterm
              and function()
                -- If there's already a Neovim instance for this cwd, switch to it
                local wezterm = require('wezterm')

                local pane = wezterm.get_current_pane()
                if pane then
                  require('wezterm').switch_pane.id(pane)
                end

                return {
                  nest = false,
                  block = false,
                }
              end
            or nil,
          post_open = vim.schedule_wrap(function(opts)
            local bufnr, winnr, ft, is_blocking, is_diff =
              opts.bufnr, opts.winnr, opts.filetype, opts.is_blocking, opts.is_diff
            local is_neo_term = vim.bo[bufnr].filetype == 'neo-term'

            if is_blocking and saved_terminal then
              -- vim.g.cmd_on_toggleterm_close = 'lua vim.api.nvim_set_current_win(' .. winnr .. ')'
              -- Hide the terminal while it's blocking
              saved_terminal:close()
              vim.schedule(function()
                vim.api.nvim_set_current_win(winnr)
              end)
            elseif not is_neo_term or is_diff then
              vim.schedule(function()
                vim.api.nvim_set_current_win(winnr)
              end)

              do
                if not vim.cfg.runtime__is_wezterm then
                  return
                end
                -- If it's not in the current wezterm pane, switch to that pane.
                require('wezterm').switch_pane.id(tonumber(os.getenv('WEZTERM_PANE')))
              end
            end

            if ft == 'gitcommit' or ft == 'gitrebase' then
              -- If the file is a git commit, create one-shot autocmd to delete it on write
              -- If you just want the toggleable terminal integration, ignore this bit and only use the
              -- code in the else block
              vim.api.nvim_create_autocmd('BufWritePost', {
                buffer = bufnr,
                once = true,
                callback = vim.schedule_wrap(function()
                  vim.api.nvim_buf_delete(bufnr, {})
                end),
              })
            end
          end),
          block_end = vim.schedule_wrap(function(opts)
            if vim.cfg.runtime__is_wezterm and type(opts.data) == 'table' and opts.data.pane then
              require('wezterm').switch_pane.id(opts.data.pane)
            end
            if saved_terminal then
              saved_terminal:open()
              saved_terminal = nil
              vim.g.cmd_on_toggleterm_close = nil
            end
            if is_neo_term then
              is_neo_term = false
            end
          end),
        },
        window = {
          open = 'split',
        },
        nest_if_no_args = true,
        integrations = {
          wezterm = vim.cfg.runtime__is_wezterm,
        },
      }
    end,
  },
})

plug({
  'nyngwang/NeoTerm.lua',
  cmd = { 'NeoTermToggle' },
  ft = 'terminal',
  keys = {
    {
      '<M-Tab>',
      function()
        vim.cmd('NeoTermToggle')
      end,
      desc = 'Enter neoterm',
    },
    {
      '<M-Tab>',
      '<cmd>NeoTermToggle<cr>',
      desc = 'Back to normal',
      mode = 't',
    },
  },
  config = function()
    require('neo-term').setup({
      exclude_filetype = { 'oil' },
      term_mode_hl = 'Normal',
    })
  end,
})
