-- debugger and runner.
-- local cmdstr = require('userlib.runtime.keymap').cmdstr
local au = require('userlib.runtime.au')
local pack = require('userlib.runtime.pack')
local libutils = require('userlib.runtime.utils')

---@param config {args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == 'function' and (config.args() or {}) or config.args or {}
  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.input('Run with args: ', table.concat(args, ' ')) --[[@as string]]
    return vim.split(vim.fn.expand(new_args) --[[@as string]], ' ')
  end
  return config
end

---- dap
pack.plug({
  --- mac sonoma 14.4< not work: https://github.com/vadimcn/codelldb/discussions/456#discussioncomment-8846290
  cond = not vim.cfg.runtime__starts_as_gittool,
  'mfussenegger/nvim-dap',
  dependencies = {
    { 'theHamsta/nvim-dap-virtual-text', opts = {} },
    'rcarriga/nvim-dap-ui',
  },
  keys = {
    { '<leader>d', '', desc = '+debug', mode = { 'n', 'v' } },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end,
      desc = 'Breakpoint Condition',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Toggle Breakpoint',
    },
    {
      '<leader>dc',
      function()
        require('dap').continue()
      end,
      desc = 'Continue',
    },
    {
      '<leader>da',
      function()
        require('dap').continue({ before = get_args })
      end,
      desc = 'Run with Args',
    },
    {
      '<leader>dC',
      function()
        require('dap').run_to_cursor()
      end,
      desc = 'Run to Cursor',
    },
    {
      '<leader>dg',
      function()
        require('dap').goto_()
      end,
      desc = 'Go to Line (No Execute)',
    },
    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'Step Into',
    },
    {
      '<leader>dj',
      function()
        require('dap').down()
      end,
      desc = 'Down',
    },
    {
      '<leader>dk',
      function()
        require('dap').up()
      end,
      desc = 'Up',
    },
    {
      '<leader>dl',
      function()
        require('dap').run_last()
      end,
      desc = 'Run Last',
    },
    {
      '<leader>do',
      function()
        require('dap').step_out()
      end,
      desc = 'Step Out',
    },
    {
      '<leader>dO',
      function()
        require('dap').step_over()
      end,
      desc = 'Step Over',
    },
    {
      '<leader>dp',
      function()
        require('dap').pause()
      end,
      desc = 'Pause',
    },
    {
      '<leader>dr',
      function()
        require('dap').repl.toggle()
      end,
      desc = 'Toggle REPL',
    },
    {
      '<leader>ds',
      function()
        require('dap').session()
      end,
      desc = 'Session',
    },
    {
      '<leader>dt',
      function()
        require('dap').terminate()
      end,
      desc = 'Terminate',
    },
    {
      '<leader>dw',
      function()
        require('dap.ui.widgets').hover()
      end,
      desc = 'Widgets',
    },
    {
      '<leader>dL',
      function()
        require('dap').set_log_level('TRACE')
      end,
      desc = 'Seup logger level',
    },
  },
  config = function()
    local dap = require('dap')
    local utils = require('userlib.runtime.utils')

    vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })

    for name, sign in pairs(require('userlib.icons.dap')) do
      sign = type(sign) == 'table' and sign or { sign }
      vim.fn.sign_define(
        'Dap' .. name,
        { text = sign[1], texthl = sign[2] or 'DiagnosticInfo', linehl = sign[3], numhl = sign[3] }
      )
    end

    -- setup dap config by VsCode launch.json file
    local vscode = require('dap.ext.vscode')
    local json = require('plenary.json')
    vscode.json_decode = function(str)
      return vim.json.decode(json.json_strip_comments(str))
    end

    -- ╭──────────────────────────────────────────────────────────╮
    -- │ Adapters                                                 │
    -- ╰──────────────────────────────────────────────────────────╯
    -- NODE / TYPESCRIPT
    dap.adapters.node2 = {
      type = 'executable',
      command = 'node',
      -- FIXME: use nix
      args = { vim.fn.stdpath('data') .. '/mason/packages/node-debug2-adapter/out/src/nodeDebug.js' },
    }

    -- Chrome
    dap.adapters.chrome = {
      type = 'executable',
      command = 'node',
      -- FIXME: use nix
      args = { vim.fn.stdpath('data') .. '/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js' },
    }

    if vim.cfg.codelldb_path then
      local liblldb_path = vim.fn.fnamemodify(vim.cfg.liblldb_path, ':r')
      liblldb_path = (liblldb_path .. '%s'):format(vim.uv.os_uname().sysname == 'Linux' and '.so' or '.dylib')

      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        host = '127.0.0.1',
        executable = {
          command = vim.cfg.codelldb_path,
          args = { '--liblldb', liblldb_path, '--port', '${port}' },
        },
      }
    end

    local rustcfg = dap.configurations.rust or {}
    table.insert(rustcfg, {
      name = 'attache_to_process',
      type = 'codelldb',
      request = 'attach',
      pid = require('dap.utils').pick_process,
      args = {},
      cwd = '${workspaceFolder}',
    })
    dap.configurations.rust = rustcfg

    dap.configurations.javascript = {
      {
        type = 'node2',
        request = 'launch',
        program = '${file}',
        cwd = utils.get_root(),
        sourceMaps = true,
        protocol = 'inspector',
        console = 'integratedTerminal',
      },
    }

    dap.configurations.javascript = {
      {
        type = 'chrome',
        request = 'attach',
        program = '${file}',
        cwd = utils.get_root(),
        sourceMaps = true,
        protocol = 'inspector',
        port = 9222,
        webRoot = '${workspaceFolder}',
      },
    }

    dap.configurations.javascriptreact = {
      {
        type = 'chrome',
        request = 'attach',
        program = '${file}',
        cwd = utils.get_root(),
        sourceMaps = true,
        protocol = 'inspector',
        port = 9222,
        webRoot = '${workspaceFolder}',
      },
    }

    dap.configurations.typescriptreact = {
      {
        type = 'chrome',
        request = 'attach',
        program = '${file}',
        cwd = utils.get_root(),
        sourceMaps = true,
        protocol = 'inspector',
        port = 9222,
        webRoot = '${workspaceFolder}',
      },
    }

    require('userlib.runtime.au').exec_useraucmd('PluginDapLoaded', {
      data = {},
    })
  end,
})

-- mason.nvim integration
pack.plug({
  'jay-babu/mason-nvim-dap.nvim',
  dependencies = 'mason.nvim',
  lazy = true,
  event = { 'User PluginDapLoaded' },
  cmd = { 'DapInstall', 'DapUninstall' },
  opts = {
    -- Makes a best effort to setup the various debuggers with
    -- reasonable debug configurations
    automatic_installation = true,

    -- You can provide additional configuration to the handlers,
    -- see mason-nvim-dap README for more information
    handlers = {},

    -- You'll need to check that you have the required things installed
    -- online, please don't ask me how to install them :)
    ensure_installed = {
      -- Update this to ensure that you have the debuggers for the langs you want
    },
  },
  -- mason-nvim-dap is loaded when nvim-dap loads
  config = function() end,
})

pack.plug({
  {
    'nvim-neotest/neotest',
    cond = not vim.cfg.runtime__starts_as_gittool,
    optional = true,
    opts = function(_, opts)
      if vim.cfg.edit__cmp_provider ~= 'coc' then
        return opts
      end
      opts.adapters = opts.adapters or {}
      vim.list_extend(opts.adapters, {
        require('neotest-vim-test')({
          allow_file_types = {
            'rust',
            'typescript',
            'javascript',
            'typescriptreact',
            'javascriptreact',
          },
        }),
      })
      return opts
    end,
  },
})

pack.plug({
  'rcarriga/nvim-dap-ui',
  keys = {
    {
      '<leader>du',
      function()
        require('dapui').toggle({})
      end,
      desc = 'Dap UI',
    },
    {
      '<leader>de',
      function()
        require('dapui').eval()
      end,
      desc = 'Eval',
      mode = { 'n', 'v' },
    },
    {
      '<leader>df',
      function()
        require('dapui').float_element()
      end,
      desc = 'Open floating',
    },
  },
  dependencies = { 'nvim-neotest/nvim-nio' },
  opts = {},
  config = function(_, opts)
    local dap = require('dap')
    local dapui = require('dapui')
    dapui.setup(opts)
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open({})
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close({})
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close({})
    end
  end,
})

---neotest
pack.plug({
  cmd = 'Neotest',
  'nvim-neotest/neotest',
  cond = not vim.cfg.runtime__starts_as_gittool,
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    -- lang:js
    'haydenmeade/neotest-jest',
    -- lang:rust
    -- https://nexte.st/
    -- 'rouge8/neotest-rust',
  },
  init = au.schedule_lazy(function()
    au.on_filetype('neotest-output', 'setlocal wrap')

    require('userlib.legendary').register('neotest', function(lg)
      lg.funcs({
        {
          function()
            require('neotest').summary.toggle()
          end,
          description = 'Neotest toggle summary',
        },
        {
          function()
            require('neotest').run.run()
          end,
          description = 'Neotest run',
        },
        {
          function()
            require('neotest').stop()
          end,
          description = 'Neotest stop',
        },
        -- run current file.
        {
          function()
            require('neotest').run.run(vim.fn.expand('%'))
          end,
          description = 'Neotest run current file',
        },
        {
          function()
            require('neotest').run({ strategy = 'dap' })
          end,
          description = 'Debug the nearest test',
        },
      })
    end)
  end),
  opts = function()
    return {
      adapters = {
        require('neotest-jest')({
          jestCommand = 'pnpm test --',
          env = { CI = true },
          cwd = function(path)
            return require('userlib.runtime.utils').get_root()
          end,
        }),
      },

      diagnostic = {
        enabled = true,
      },
      floating = {
        border = 'single',
        max_height = 0.6,
        max_width = 0.9,
      },
      highlights = {
        adapter_name = 'NeotestAdapterName',
        border = 'NeotestBorder',
        dir = 'NeotestDir',
        expand_marker = 'NeotestExpandMarker',
        failed = 'NeotestFailed',
        file = 'NeotestFile',
        focused = 'NeotestFocused',
        indent = 'NeotestIndent',
        namespace = 'NeotestNamespace',
        passed = 'NeotestPassed',
        running = 'NeotestRunning',
        skipped = 'NeotestSkipped',
        test = 'NeotestTest',
      },
      icons = {
        child_indent = '│',
        child_prefix = '├',
        collapsed = '─',
        expanded = '╮',
        failed = '✖',
        final_child_indent = ' ',
        final_child_prefix = '╰',
        non_collapsible = '─',
        passed = '✔',
        running = '󰦖',
        skipped = 'ⓙ',
        unknown = '?',
      },
      output = {
        enabled = true,
        open_on_run = true,
      },
      run = {
        enabled = true,
      },
      quickfix = {
        enabled = true,
        open = false,
      },
      status = {
        enabled = true,
      },
      strategies = {
        integrated = {
          height = 40,
          width = 120,
        },
      },
      summary = {
        enabled = true,
        expand_errors = true,
        follow = true,
        mappings = {
          attach = 'a',
          expand = { '<CR>', '<2-LeftMouse>' },
          expand_all = 'e',
          jumpto = 'i',
          output = 'o',
          run = 'r',
          short = 'O',
          stop = 'u',
        },
      },
    }
  end,
  config = function(_, opts)
    local present, neotest = pcall(require, 'neotest')
    if not present then
      return
    end

    if opts.adapters then
      local adapters = {}
      for name, config in pairs(opts.adapters or {}) do
        if type(name) == 'number' then
          if type(config) == 'string' then
            config = require(config)
          end
          adapters[#adapters + 1] = config
        elseif config ~= false then
          local adapter = require(name)
          if type(config) == 'table' and not vim.tbl_isempty(config) then
            local meta = getmetatable(adapter)
            if adapter.setup then
              adapter.setup(config)
            elseif meta and meta.__call then
              adapter(config)
            else
              error('Adapter ' .. name .. ' does not support setup')
            end
          end
          adapters[#adapters + 1] = adapter
        end
      end
      opts.adapters = adapters
    end

    neotest.setup(opts)
  end,
})

pack.plug({
  'nvim-neotest/neotest-vim-test',
  event = { 'BufRead' },
  cond = not vim.cfg.runtime__starts_as_gittool,
  dependencies = {
    'nvim-neotest/neotest',
    {
      'vim-test/vim-test',
      cmd = {
        'TestNearest',
        'TestClass',
        'TestFile',
        'TestSuite',
        'TestLast',
        'TestVisit',
      },
      init = au.schedule_lazy(function()
        vim.g['test#strategy'] = 'toggleterm'
        -------
        vim.g['test#neovim#start_normal'] = 1
        vim.g['test#toggleterm#start_normal'] = 1
        vim.g['test#neovim_sticky#start_normal'] = 0
        vim.g['test#neovim_sticky#kill_previous'] = 1
        vim.g['test#preserve_screen'] = 0
        vim.g['test#neovim_sticky#reopen_window'] = 1
        vim.g['test#echo_command'] = 0

        require('userlib.legendary').register('vim-test', function(lg)
          lg.funcs({
            {
              vim.schedule_wrap(function()
                local mark = 't'
                local _, error = pcall(vim.api.nvim_command, ([['%s]]):format(mark))
                if error then
                  return
                end
                vim.schedule(function()
                  vim.cmd('TestNearest')
                end)
              end),
              description = 'vim test: test mark t position',
            },
          })
          lg.commands({
            {
              ':TestNearest',
              description = 'vim test: test nearest',
            },
            {
              ':TestFile',
              description = 'vim test: test file',
            },
            {
              ':TestLast',
              description = 'vim test: test last',
            },
            {
              ':TestVisit',
              description = 'vim test: test last visit',
            },
          })
        end)
      end),
    },
  },
  enabled = vim.cfg.edit__cmp_provider == 'coc',
})

---overseer|task runner
pack.plug({
  -- https://github.com/stevearc/overseer.nvim
  'stevearc/overseer.nvim',
  dependencies = {
    'mfussenegger/nvim-dap',
  },
  cmd = {
    'OverseerRestartLast',
    'OverseerRun',
    'OverseerOpen',
    'OverseerToggle',
    'OverseerClose',
    'OverseerSaveBundle',
    'OverseerLoadBundle',
    'OverseerDeleteBundle',
    'OverseerRunCmd',
    -- Show infos like checkhealth
    'OverseerInfo',
    'OverseerBuild',
    -- run action on last.
    'OverseerQuickAction',
    -- select running task and perf action: kill or restart etc.
    'OverseerTaskAction',
    'OverseerClearCache',
  },
  keys = {
    { '<localleader>o;', '<cmd>OverseerRestartLast<cr>', desc = 'Restart last task' },
    { '<localleader>oo', '<cmd>OverseerToggle<cr>', desc = 'Toggle' },
    { '<localleader>or', '<cmd>OverseerRun<cr>', desc = 'Run' },
    { '<localleader>oR', '<cmd>OverseerRunCmd<cr>', desc = 'Run shell cmd' },
    { '<localleader>oc', '<cmd>OverseerClose<cr>', desc = 'Close' },
    { '<localleader>os', '<cmd>OverseerSaveBundle<cr>', desc = 'Save bundle' },
    { '<localleader>ol', '<cmd>OverseerLoadBundle<cr>', desc = 'Load bundle' },
    { '<localleader>od', '<cmd>OverseerDeleteBundle<cr>', desc = 'Delete bundle' },
    {
      '<localleader>ov',
      '<cmd>lua require("userlib.overseers.utils").open_vsplit_last()<cr>',
      desc = 'Open last in vsplit',
    },
    {
      '<localleader>oq',
      '<cmd>OverseerQuickAction<cr>',
      desc = 'Run an action on the most recent task, or the task under the cursor',
    },
    {
      '<localleader>ot',
      function()
        local ovutils = require('userlib.overseers.utils')
        ovutils.run_action_on_tasks({
          unique = true,
          recent_first = true,
        })
      end,
      desc = 'List tasks',
    },
    -- { '<localleader>ot', '<cmd>OverseerTaskAction<cr>', desc = 'Select a task to run an action on' },
    { '<localleader>oC', '<cmd>OverseerClearCache<cr>', desc = 'Clear cache' },
  },
  opts = {
    -- https://github.com/stevearc/overseer.nvim/blob/master/doc/reference.md#setup-options
    -- strategy = "terminal",
    strategy = 'terminal',
    templates = { 'builtin' },
    auto_detect_success_color = true,
    dap = true,
    task_list = {
      default_detail = 2,
      max_width = { 100, 0.6 },
      min_width = { 50, 0.4 },
      direction = 'right',
      bindings = {
        ['<C-t>'] = '<CMD>OverseerQuickAction open tab<CR>',
        ['='] = 'IncreaseDetail',
        ['-'] = 'DecreaseDetail',
        ['<C-y>'] = 'ScrollOutputUp',
        ['<C-n>'] = 'ScrollOutputDown',
        ['<C-k>'] = false,
        ['<C-j>'] = false,
        ['<C-l>'] = false,
        ['<C-h>'] = false,
      },
    },
    form = {
      border = 'single',
    },
    confirm = {
      border = 'single',
    },
    task_win = {
      border = 'single',
    },
    help_win = {
      border = 'single',
    },
    task_launcher = {},
  },
  config = function(_, opts)
    vim.g.plugin_overseer_loaded = 1
    local overseer = require('overseer')
    local overseer_vscode_variables = require('overseer.template.vscode.variables')
    local precalculate_vars = overseer_vscode_variables.precalculate_vars

    overseer_vscode_variables.precalculate_vars = function()
      local tbl = precalculate_vars()
      tbl['workspaceFolder'] = vim.cfg.runtime__starts_cwd
      tbl['workspaceRoot'] = vim.cfg.runtime__starts_cwd
      tbl['fileWorkspaceFolder'] = libutils.get_root()
      tbl['workspaceFolderBasename'] = vim.fs.basename(vim.cfg.runtime__starts_cwd)
      return tbl
    end

    overseer.setup(opts)

    --- add variable for vscode tasks.
    -- overseer.add_template_hook({ module = 'vscode', }, function(task_defn, _util)
    -- end)

    -- if has_dap then
    --   require("dap.ext.vscode").json_decode = require("overseer.util").decode_json
    -- end
    vim.api.nvim_create_user_command('OverseerRestartLast', function()
      local tasks = overseer.list_tasks({ recent_first = true })
      if vim.tbl_isempty(tasks) then
        vim.notify('No tasks found', vim.log.levels.WARN)
      else
        overseer.run_action(tasks[1], 'restart')
      end
    end, {})
  end,
  init = au.schedule_lazy(function()
    require('userlib.legendary').register('overseer', function(lg)
      lg.commands({
        {
          'OverseerRun',
          description = 'Overseer run',
        },
        {
          'OverseerClose',
          description = 'Overseer close',
        },
        {
          'OverseerOpen',
          description = 'Overseer open',
        },
        {
          'OverseerToggle',
          description = 'Overseer toggle',
        },
      })

      lg.funcs({
        {
          function()
            local overseer = require('overseer')
            local tasks = overseer.list_tasks({ recent_first = true })
            if vim.tbl_isempty(tasks) then
              vim.notify('No tasks found', vim.log.levels.WARN)
            else
              overseer.run_action(tasks[1], 'restart')
            end
          end,
          description = 'Overseer restart last',
        },
      })
    end)
  end),
})

pack.plug({
  'chrisgrieser/nvim-chainsaw',
  opts = {
    -- The marker should be a unique string, since `.removeLogs()` will remove
    -- any line with it. Emojis or strings like "[Chainsaw]" are recommended.
    marker = '🪚',

    -- emojis used for `.beepLog()`
    beepEmojis = { '🔵', '🟩', '⭐', '⭕', '💜', '🔲' },
    logStatements = {
      beepLog = {
        vue = 'console.log("%s beep %s");',
      },
      messageLog = {
        vue = 'console.log("%s ");',
      },
    },
  },
  keys = {
    {
      '<leader>rMK',
      '<cmd>lua require("chainsaw").removeLogs()<cr>',
      desc = 'Remove all logs',
    },
    {
      '<leader>rMM',
      '<cmd>lua require("chainsaw").messageLog()<cr>',
      desc = 'Add message log',
    },
    {
      '<leader>rMS',
      '<cmd>lua require("chainsaw").stacktraceLog()<cr>',
      desc = 'Add stacktrace log',
    },
    {
      '<leader>rMB',
      '<cmd>lua require("chainsaw").beepLog()<cr>',
      desc = 'Add quick beep log',
    },
  },
})
