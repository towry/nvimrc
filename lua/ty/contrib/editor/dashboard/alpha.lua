local M = {}

local dashboard = nil

function M.init_manually()
  -- ╭──────────────────────────────────────────────────────────╮
  -- │ Hide tabline and statusline on startup screen            │
  -- ╰──────────────────────────────────────────────────────────╯
  vim.api.nvim_create_augroup('alpha_tabline', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = 'alpha_tabline',
    pattern = 'alpha',
    command = 'set showtabline=0 laststatus=0 noruler',
  })

  vim.api.nvim_create_autocmd('FileType', {
    group = 'alpha_tabline',
    pattern = 'alpha',
    callback = function()
      vim.api.nvim_create_autocmd('BufUnload', {
        group = 'alpha_tabline',
        buffer = 0,
        command = 'set showtabline=' .. vim.opt.showtabline:get() .. ' ruler laststatus=3',
      })
    end,
  })
  -- vim.api.nvim_create_autocmd("User", {
  --   once = true,
  --   pattern = "LazyVimStarted",
  --   callback = function()
  --     if not dashboard then return end
  --     dashboard.section.footer.val = footer()
  --   end,
  -- })
end

-- ╭──────────────────────────────────────────────────────────╮
-- │ Footer                                                   │
-- ╰──────────────────────────────────────────────────────────╯
local function footer()
  local ok, plugins = pcall(function() return require('lazy').stats().count end)
  if not ok then plugins = 0 end
  local startup_time = require('lazy').stats().startuptime or 0
  local v = vim.version()
  return string.format(' v%d.%d.%d   %d   %sms ', v.major, v.minor, v.patch, plugins, startup_time)
end

function M.setup()
  local present, alpha = pcall(require, 'alpha')
  if not present then return end
  dashboard = require('alpha.themes.dashboard')
  local icons = require('ty.contrib.ui.icons')
  local if_nil = vim.F.if_nil

  vim.cmd('Lazy load vim-tips')
  local tip = vim.api.nvim_eval('g:GetTip()')

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ Header                                                   │
  -- ╰──────────────────────────────────────────────────────────╯

  local header = {
    '                              ',
    tip,
    '                              ',
  }
  dashboard.section.header.type = 'text'
  dashboard.section.header.val = header
  dashboard.section.header.opts = {
    position = 'center',
    hl = 'Normal',
  }

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ Heading Info                                             │
  -- ╰──────────────────────────────────────────────────────────╯

  local thingy = io.popen('echo "$(date +%a) $(date +%d) $(date +%b)" | tr -d "\n"')
  if thingy == nil then return end
  local date = thingy:read('*a')
  thingy:close()

  local datetime = os.date(' %H:%M')

  local hi_top_section = {
    type = 'text',
    val = '┌────────────   Today is '
    .. date
    .. ' ────────────┐',
    opts = {
      position = 'center',
      hl = 'NormalInfo',
    },
  }

  local hi_middle_section = {
    type = 'text',
    val = '│                                                │',
    opts = {
      position = 'center',
      hl = 'NormalInfo',
    },
  }

  local hi_bottom_section = {
    type = 'text',
    val = '└───══───══───══───  '
    .. datetime
    .. '  ───══───══───══────┘',
    opts = {
      position = 'center',
      hl = 'NormalInfo',
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
      width = 50,
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
      '<Nop>',
      icons.timer .. ' ' .. 'Load Current Dir Session',
      '<cmd>SessionManager load_current_dir_session<CR>',
      {}
    ),
    button(
      'SPC s h',
      icons.fileRecent .. ' ' .. 'Recents',
      '<cmd>Telescope oldfiles cwd_only=true hidden=true<CR>',
      {}
    ),
    button('<F8>', icons.fileNoBg .. ' ' .. 'Find File', '<cmd>lua Ty.Func.explorer.project_files()<CR>', {}),
    button('<F9>', icons.t .. ' ' .. 'Find Word', '<cmd>lua Ty.Func.explorer.multi_rg_find_word()<CR>', {}),
    button('~', '  ' .. ' ' .. 'Plugins', '<cmd>Lazy<CR>', {}),
    button('-', icons.exit .. ' ' .. 'Exit', '<cmd>exit<CR>', {}),
  }

  dashboard.section.footer.val = {
    footer(),
  }
  dashboard.section.footer.opts = {
    position = 'center',
    hl = 'Normal',
  }

  local section = {
    header = dashboard.section.header,
    hi_top_section = hi_top_section,
    hi_middle_section = hi_middle_section,
    hi_bottom_section = hi_bottom_section,
    buttons = dashboard.section.buttons,
    footer = dashboard.section.footer,
  }

  -- ╭──────────────────────────────────────────────────────────╮
  -- │ Setup                                                    │
  -- ╰─────────����────────────────────────────────────��───────────╯

  local opts = {
    layout = {
      { type = 'padding', val = 2 },
      section.header,
      { type = 'padding', val = 1 },
      section.hi_top_section,
      section.hi_middle_section,
      section.hi_bottom_section,
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
