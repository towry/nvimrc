local au = require('userlib.runtime.au')
local keymap = require('userlib.runtime.keymap')
local set, cmd, cmd_modcall = keymap.set, keymap.cmdstr, keymap.cmd_modcall

local M = {}

local function setup_basic()
  set('n', '[b', ':bprevious<CR>', {
    desc = 'Previous buffer',
  })
  set('n', ']b', ':bnext<cr>', {
    desc = 'Next buffer',
  })
  --- quickly go into cmd
  set('n', '<C-;>', ':<C-u>', {
    expr = false,
    noremap = true,
  })
  set('n', '<localleader>n', function()
    require('userlib.workflow.run-normal-keys')()
  end, {
    noremap = true,
    silent = false,
    desc = 'execute normal keys',
  })
  set('n', '<leader>rs', ':lua require("userlib.workflow.run-shell-cmd")()<cr>', {
    silent = true,
    noremap = true,
    desc = 'run shell command',
  })
  set('i', '<C-;>', '<esc>:<C-u>', {
    expr = false,
    noremap = true,
    desc = "Enter cmdline easily"
  })
  --- command line history.
  set('c', '<C-;>', function()
    return [[lua require('userlib.telescope.pickers').command_history()<CR>]]
    --   return vim.api.nvim_replace_termcodes('<C-u><C-p>', true, false, true)
  end, {
    expr = true,
    noremap = false,
    desc = 'Previous command in cmdline',
  })
  set('c', '<C-/>', function()
    return vim.api.nvim_replace_termcodes('<C-r>*', true, false, true)
  end, {
    expr = true,
    noremap = false,
    desc = 'Insert selection register into search',
  })
  ---///
  --- tab is mapped to buffers, since tab&<c-i> has same func, we
  --- need to map <c-i> to its original func.
  set('n', '<C-i>', '<C-i>', {
    noremap = true,
    expr = false,
  })
  --- provided by rsi.vim
  -- set('i', '<C-e>', '<End>', {
  --   desc = 'Insert mode: move to end of line',
  -- })
  set('n', '<leader>/q', ':qa<cr>', {
    desc = 'Quit vim'
  })


  set(
    'n',
    '<C-S-A-p>',
    cmd([[lua require('legendary').find({ filters = require('legendary.filters').current_mode() })]]),
    {
      desc = 'Open Command Palette',
    }
  )

  set('n', '<ESC>', cmd('noh'), {
    desc = 'Clear search highlight',
  })
  set('v', '<', '<gv', {
    desc = 'Keep visual mode indenting, left',
  })
  set('v', '>', '>gv', {
    desc = 'Keep visual mode indenting, right',
  })
  set('v', '`', 'u', {
    desc = 'Case change in visual mode'
  })

  set({ 'v', 'i' }, '<F1>', cmd('bufdo update'), {
    desc = 'Save all files',
  })
  set({ 'n', 'i' }, '<D-S>', cmd('bufdo update'), {
    desc = 'Save all files',
  })
  set({ 'n', 'i' }, '<D-s>', cmd('update'), {
    desc = 'Save current buffer',
  })
  set('n', '<localleader>w', cmd('update'), {
    desc = 'Save current buffer',
  })

  -- yanks
  set({ 'n', 'v' }, 'd', function()
    -- NOTE: add different char for different buffer, for example, in oil, use o|O
    if vim.v.register == 'd' or vim.v.register == 'D' then
      return '"' .. vim.v.register .. 'd'
    end
    return '"dd'
  end, {
    silent = true,
    desc = 'Delete char and yank to register d',
    expr = true,
  })
  set({ 'n', 'v' }, 'D', '"dD', {
    desc = 'Delete to end of line and yank to register d',
    silent = true,
    expr = true,
  })
  --- do not cut on normal mode.
  set({ 'n', 'v' }, 'x', function()
    if vim.v.register == 'x' or vim.v.register == 'X' then
      return '"' .. vim.v.register .. 'x'
    end
    return '"xx'
  end, {
    expr = true,
    silent = true,
    desc = 'Cut chars and do not yank to register',
  })
  set({ 'n', 'v' }, 'X', function()
    if vim.v.register == 'x' or vim.v.register == 'X' then
      return '"' .. vim.v.register .. 'X'
    end
    return '"xX'
  end, {
    expr = true,
    silent = true,
    desc = 'Cut chars and do not yank to register',
  })

  ---gx
  if vim.fn.has('macunix') == 1 then
    set('n', 'gx', cmd('silent execute "!open " . shellescape("<cWORD>")'), {
      desc = 'Open file under cursor',
    })
  else
    set('n', 'gx', cmd('silent execute "!xdg-open " . shellescape("<cWORD>")'), {
      desc = 'Open file under cursor',
    })
  end

  set('n', 'H', '^', {
    desc = 'Move to first non-blank character of the line',
  })
  set('n', 'L', '$', {
    desc = 'Move to last non-blank character of the line',
  })

  set('n', 'Y', 'y$', {
    desc = 'Yank to end of line',
  })
  set({ 'v', 'x' }, 'K', ":move '<-2<CR>gv-gv", {
    desc = 'Move selected line / block of text in visual mode up',
  })
  set({ 'v', 'x' }, 'J', ":move '>+1<CR>gv-gv", {
    desc = 'Move selected line / block of text in visual mode down',
  })

  --- buffers
  set('n', '<leader>b]', cmd_modcall('userlib.runtime.buffer', 'next_unsaved_buf()'), {
    desc = 'Next unsaved buffer'
  })
  set('n', '<leader>b[', cmd_modcall('userlib.runtime.buffer', 'prev_unsaved_buf()'), {
    desc = 'Next unsaved buffer'
  })
  set('n', '<leader>bu', [[:earlier 1f<cr>]], {
    desc = 'Discard buffer changes'
  })
  set('n', '<leader>bd', function()
    -- TODO: select next buffer.
    vim.cmd('bdelete')
  end, {
    desc = 'Close buffer and window'
  })

  for i = 1, 9 do
    set('n', '<space>' .. i, cmd(i .. 'wincmd w'), {
      desc = 'which_key_ignore',
    })
  end

  set('n', 'qq', cmd([[:qa]]), {
    desc = 'Quit all',
    noremap = true,
    nowait = true,
  })
  set('c', '<C-q>', ('<C-u>qa<CR>'), {
    desc = 'Make sure <C-q> do not insert weird chars',
    nowait = true,
  })
end

function M.setup()
  setup_basic()
end

return M
