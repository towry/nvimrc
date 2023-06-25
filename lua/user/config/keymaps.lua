local au = require('libs.runtime.au')
local keymap = require('libs.runtime.keymap')
local set, cmd, cmd_modcall = keymap.set, keymap.cmdstr, keymap.cmd_modcall

local M = {}

local function setup_basic()
  set('n', '<C-;>', ':<C-u>', {
    expr = false,
    noremap = true,
  })
  --- tab is mapped to buffers, since tab&<c-i> has same func, we
  --- need to map <c-i> to its original func.
  set('n', '<C-i>', '<C-i>', {
    noremap = true,
    expr = false,
  })
  set('i', '<C-e>', '<End>', {
    desc = 'Insert mode: move to end of line',
  })
  -- set('n', '<C-z>', '<ESC> u', {
  --   desc = 'N: Undo, no more background key',
  -- })
  -- set('i', '<C-z>', '<ESC> u', {
  --   desc = 'I: Undo, no more background key',
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

  -- works with kitty
  set('n', '<Char-0xAA>', cmd('update'), {
    desc = 'N: Save current file by <command-s>',
  })
  set('i', '<Char-0xAA>', '<ESC>:update<cr>', {
    desc = 'I: Save current file by <command-s>',
  })

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

  set({ 'v', 'i' }, '<F1>', cmd('wa'), {
    desc = 'Save all files',
  })

  -- yanks
  set('n', 'd', '"xd', {
    desc = 'Delete char and yank to register x',
  })
  set('n', 'D', '"xD', {
    desc = 'Delete to end of line and yank to register x',
  })
  set('v', 'd', '"xd', {
    desc = 'Delete char and yank to register x',
  })
  set('v', 'D', '"xD', {
    desc = 'Delete to end of line and yank to register x',
  })
  set('n', '<Char-0xAB>', '"*x', {
    desc = 'Cut chars and yank to register *',
    remap = false,
  })
  set('v', '<Char-0xAB>', '"*x', {
    desc = 'Cut chars and yank to register *',
    remap = false,
  })
  set('n', 'x', '"_x', {
    desc = 'Cut chars and do not yank to register',
  })
  set('n', 'X', '"_X', {
    desc = 'Cut chars and do not yank to register',
  })
  set('v', 'x', '"_x', {
    desc = 'Cut chars and do not yank to register',
  })
  set('v', 'X', '"_X', {
    desc = 'Cut chars and do not yank to register',
  })
  set('v', 'p', '"_dP', {
    desc = 'Do not yank on visual paste',
  })
  set('x', 'p', '"_dP', {
    desc = 'Do not yank on select paste',
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
  set('n', '<S-Tab>', ':e #<cr>', {
    desc = 'Go to previous edited Buffer',
  })
  set('n', '<leader>b]', cmd_modcall('libs.runtime.buffer', 'next_unsaved_buf()'), {
    desc = 'Next unsaved buffer'
  })
  set('n', '<leader>b[', cmd_modcall('libs.runtime.buffer', 'prev_unsaved_buf()'), {
    desc = 'Next unsaved buffer'
  })
  set('n', '<leader>bd', [[:e!<CR>]], {
    desc = 'Discard buffer changes'
  })
  set('n', '<leader>bx', function()
    vim.cmd('bdelete')
    vim.schedule(function()
      if #require('libs.runtime.buffer').list_bufnrs() <= 0 then
        local cur_empty = require('libs.runtime.buffer').get_current_empty_buffer()
        -- start_dashboard()
        au.do_useraucmd(au.user_autocmds.DoEnterDashboard_User)
        if cur_empty then
          vim.api.nvim_buf_delete(cur_empty, { force = true })
        end
      end
    end)
  end, {
    desc = 'Close buffer and window'
  })

  set('n', '<leader><space><space>', cmd([[normal! m']]), {
    desc = 'Mark jump position',
    noremap = true,
    nowait = true,
  })
end

local function setup_git()
  set('n', '<leader>gb', cmd([[require("libs.git.blame").open_blame()]]), {
    desc = 'Git open blame',
  })
end

function M.setup()
  setup_basic()
  setup_git()
end

return M
