local M = {}

local dashboard = nil
local showtabline = 0

function M.init_manually()
  showtabline = vim.opt.showtabline:get()
  -- ╭──────────────────────────────────────────────────────────╮
  -- │ Hide tabline and statusline on startup screen            │
  -- ╰──────────────────────────────────────────────────────────╯
  vim.api.nvim_create_augroup('alpha_tabline', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = 'alpha_tabline',
    pattern = 'alpha',
    command = 'setlocal showtabline=0 noruler',
  })

  vim.api.nvim_create_autocmd('FileType', {
    group = 'alpha_tabline',
    pattern = 'alpha',
    callback = function()
      vim.api.nvim_create_autocmd('BufUnload', {
        group = 'alpha_tabline',
        buffer = 0,
        callback = function()
          vim.cmd('setlocal showtabline=' .. showtabline .. ' ruler')
          vim.api.nvim_exec_autocmds('User', {
            pattern = 'DashboardDismiss',
          })
        end,
      })
    end,
  })
end

-- ╭──────────────────────────────────────────────────────────╮
-- │ Footer                                                   │
-- ╰──────────────────────────────────────────────────────────╯
local function footer()
  local ok, plugins = pcall(function() return require('lazy').stats().count end)
  if not ok then plugins = 0 end
  local stats = require('lazy').stats()
  local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
  local v = vim.version()
  return string.format(' v%d.%d.%d   %d   %sms ', v.major, v.minor, v.patch, plugins, ms)
end

function M.setup()
  local Path = require('ty.core.path')
  local present, alpha = pcall(require, 'alpha')
  if not present then return end
  dashboard = require('alpha.themes.dashboard')
  local icons = require('ty.contrib.ui.icons')
  local if_nil = vim.F.if_nil

  vim.api.nvim_create_autocmd('User', {
    pattern = 'LazyVimStarted',
    callback = function()
      dashboard.section.footer.val = footer()
      pcall(vim.cmd.AlphaRedraw)
    end,
  })

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ Header                                                   │
  -- ╰──────────────────────────────────────────────────────────╯
  local header = [[
       _,    _   _    ,_
  .o888P     Y8o8Y     Y888o.
 d88888      88888      88888b
d888888b_  _d88888b_  _d888888b
8888888888888888888888888888888
8888888888888888888888888888888
YJGS8P"Y888P"Y888P"Y888P"Y8888P
 Y888   '8'   Y8P   '8'   888Y
  '8o          V          o8'
    `                     `
  ]]

  local lines = {}
  local insert = table.insert
  for line in header:gmatch('[^\r\n]+') do
    insert(lines, line)
  end

  dashboard.section.header.type = 'text'
  dashboard.section.header.val = lines
  dashboard.section.header.opts = {
    position = 'center',
    hl = 'Normal',
  }

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ Heading Info                                             │
  -- ╰──────────────────────────────────────────────────────────╯
  local header_bottom = {
    type = 'text',
    val = "  " .. Path.home_to_tilde(vim.loop.cwd()),
    opts = {
      position = 'center',
      hl = 'VirtualTextHint',
    },
  }

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ Buttons                                                  │
  -- ╰──────────────────────────────────────────────────────────╯
  -- Copied from Alpha.nvim source code

  local leader = 'SPC'
  --- @param sc string
  --- @param txt string
  --- @param keybind string optional
  --- @param keybind_opts table optional
  local function button(sc, txt, keybind, keybind_opts)
    local sc_ = sc:gsub('%s', ''):gsub(leader, '<leader>')

    local opts = {
      position = 'center',
      shortcut = sc,
      cursor = 5,
      width = 40,
      align_shortcut = 'right',
      hl_shortcut = 'Normal',
    }
    if keybind then
      keybind_opts = if_nil(keybind_opts, { noremap = true, silent = true, nowait = true })
      opts.keymap = { 'n', sc_, keybind, keybind_opts }
    end

    local function on_press()
      -- local key = vim.api.nvim_replace_termcodes(keybind .. "<Ignore>", true, false, true)
      local key = vim.api.nvim_replace_termcodes(sc_ .. '<Ignore>', true, false, true)
      vim.api.nvim_feedkeys(key, 't', false)
    end

    return {
      type = 'button',
      val = txt,
      on_press = on_press,
      opts = opts,
    }
  end

  dashboard.section.buttons.val = {
    button(
      '/',
      icons.timer .. ' ' .. 'Load Session',
      '<cmd>SessionManager load_current_dir_session<CR>',
      {}
    ),
    button(
      'r',
      icons.fileRecent .. ' ' .. 'Recents',
      '<cmd>Telescope oldfiles cwd_only=true hidden=true<CR>',
      {}
    ),
    button('f', icons.fileNoBg .. ' ' .. 'Find File', '<cmd>lua Ty.Func.explorer.project_files()<CR>', {}),
    button('s', icons.t .. ' ' .. 'Search Content', '<cmd>lua Ty.Func.explorer.multi_rg_find_word()<CR>', {}),
    button('p', '  ' .. ' ' .. 'Plugins', '<cmd>Lazy<CR>', {}),
    button('q', icons.exit .. ' ' .. 'Exit', '<cmd>exit<CR>', {}),
  }

  dashboard.section.footer.val = {
    footer(),
  }
  dashboard.section.footer.opts = {
    position = 'center',
    hl = 'VirtualTextHint',
  }

  local section = {
    header = dashboard.section.header,
    buttons = dashboard.section.buttons,
    footer = dashboard.section.footer,
  }

  local opts = {
    layout = {
      { type = 'padding', val = 2 },
      section.header,
      { type = 'padding', val = 0 },
      header_bottom,
      { type = 'padding', val = 1 },
      section.buttons,
      { type = 'padding', val = 1 },
      section.footer,
    },
    opts = {
      margin = 5,
    },
  }

  -- disable mini.indentscope for this.
  vim.b.miniindentscope_disable = true
  alpha.setup(opts)
  M.init_manually()
end

return M
