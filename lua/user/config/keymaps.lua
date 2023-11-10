local keymap = require('userlib.runtime.keymap')
local utils = require('userlib.runtime.utils')
local set, cmd, cmd_modcall = keymap.set, keymap.cmdstr, keymap.cmd_modcall

local M = {}
local is_profiling = false

--- only do this in tmux.
local xk = utils.utf8keys({
  [ [[<D-s>]] ] = 0xAA,
  [ [[<C-'>]] ] = 0xAD,
  [ [[<C-;>]] ] = 0xAB,
  [ [[<C-i>]] ] = 0xAC,
}, true)

local function setup_basic()
  -- <C-'> to pick register from insert mode.
  set('i', xk([[<C-'>]]), function()
    vim.cmd('stopinsert')
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes('"', true, false, true))
  end, {
    silent = true,
    desc = 'Pick register from insert mode',
  })
  set('n', xk([[<C-'>]]), function() vim.fn.feedkeys(vim.api.nvim_replace_termcodes('"', true, false, true)) end, {
    silent = true,
    desc = 'Pick register from insert mode',
  })
  set('n', '[b', ':bprevious<CR>', {
    desc = 'Previous buffer',
    noremap = true,
  })
  set('n', ']b', ':bnext<cr>', {
    desc = 'Next buffer',
    noremap = true,
  })
  --- quickly go into cmd
  set('n', xk([[<C-;>]]), ':<C-u>', {
    expr = false,
    noremap = true,
  })
  set('n', '<leader>rn', function() require('userlib.workflow.run-normal-keys')() end, {
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
    desc = 'Enter cmdline easily',
  })
  --- command line history.
  set('c', xk([[<C-;>]]), function()
    return [[lua require('userlib.telescope.pickers').command_history()<CR>]]
    --   return vim.api.nvim_replace_termcodes('<C-u><C-p>', true, false, true)
  end, {
    expr = true,
    noremap = false,
    desc = 'Previous command in cmdline',
  })
  ---///
  --- tab is mapped to buffers, since tab&<c-i> has same func, we
  --- need to map <c-i> to its original func.
  set('n', xk([[<C-i>]]), '<C-i>', {
    noremap = true,
    expr = false,
  })
  --- provided by rsi.vim
  -- set('i', '<C-e>', '<End>', {
  --   desc = 'Insert mode: move to end of line',
  -- })
  set('n', '<leader>/q', ':qa<cr>', {
    desc = 'Quit vim',
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
    desc = 'Case change in visual mode',
  })

  -- set({ 'n', 'i' }, [[<D-s>]], cmd('bufdo update'), {
  --   desc = 'Save all files',
  -- })
  set({ 'n', 'i' }, xk([[<D-s>]]), '<ESC>:silent! update<cr>', {
    desc = 'Save current buffer',
    silent = true,
  })
  set('n', '<leader>bw', cmd('silent! update'), {
    desc = 'Save current buffer',
    silent = true,
  })

  -- yanks
  set({ 'n', 'v' }, 'd', function()
    -- NOTE: add different char for different buffer, for example, in oil, use o|O
    if vim.v.register == 'd' or vim.v.register == 'D' then return '"' .. vim.v.register .. 'd' end
    return '"dd'
  end, {
    silent = true,
    desc = 'Delete char and yank to register d',
    noremap = true,
    expr = true,
  })
  set({ 'n', 'v' }, 'D', '"dD', {
    desc = 'Delete to end of line and yank to register d',
    silent = true,
    expr = true,
    noremap = true,
  })
  --- do not cut on normal mode.
  set({ 'n', 'v' }, 'x', function()
    if vim.v.register == 'x' or vim.v.register == 'X' then return '"' .. vim.v.register .. 'x' end
    return '"xx'
  end, {
    expr = true,
    silent = true,
    noremap = true,
    desc = 'Cut chars and do not yank to register',
  })
  set({ 'n', 'v' }, 'X', function()
    if vim.v.register == 'x' or vim.v.register == 'X' then return '"' .. vim.v.register .. 'X' end
    return '"xX'
  end, {
    expr = true,
    silent = true,
    noremap = true,
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
    desc = 'Next unsaved buffer',
  })
  set('n', '<leader>b[', cmd_modcall('userlib.runtime.buffer', 'prev_unsaved_buf()'), {
    desc = 'Next unsaved buffer',
  })
  set('n', '<leader>be', [[:earlier 1f<cr>]], {
    desc = 'Most earlier buffer changes',
  })
  set('n', '<leader>bd', function()
    -- TODO: select next buffer.
    vim.cmd('bdelete')
  end, {
    desc = 'Close buffer and window',
  })

  for i = 1, 9 do
    set('n', '<space>' .. i, cmd(i .. 'tabnext'), {
      desc = 'which_key_ignore',
    })
  end
  set('n', '<leader>tn', cmd('tabnew'), {
    desc = 'New tab',
  })
  -- map alt+number to navigate to window by ${number} . wincmd w<cr>
  for i = 1, 9 do
    set('n', '<M-' .. i .. '>', cmd(i .. 'wincmd w'), {
      desc = 'which_key_ignore',
    })
  end
  set('n', '<M-`>', cmd('wincmd p'), {
    desc = 'which_key_ignore',
  })

  set('n', 'qq', cmd([[:qa]]), {
    desc = 'Quit all',
    noremap = true,
    nowait = true,
  })
  set('c', '<C-q>', '<C-u>qa<CR>', {
    desc = 'Make sure <C-q> do not insert weird chars',
    nowait = true,
  })

  -- works with quickfix
  set('n', '[q', ':cprev<cr>', {
    desc = 'Jump to previous quickfix item',
  })
  set('n', ']q', ':cnext<cr>', {
    desc = 'Jump to next quickfix item',
  })

  set('n', '<leader>tp', function()
    if is_profiling then
      is_profiling = false
      Ty.StopProfile()
      vim.notify('profile stopped', vim.log.levels.INFO)
      return
    end
    is_profiling = true
    Ty.StartProfile('profile.log', { flame = true })
  end, {
    desc = 'Toggle profile',
  })

  local tip_is_loading = false
  set('n', '<leader>/t', function()
    if tip_is_loading then return end
    local job = require 'plenary.job'
    job:new({
      command = 'curl',
      args = { 'https://vtip.43z.one' },
      on_exit = function(j, exit_code)
        tip_is_loading = false
        local res = table.concat(j:result())
        if exit_code ~= 0 then
          res = 'Error fetching tip: ' .. res
        end
        print(res)
      end,
    }):start()
  end, {
    desc = 'Get a random tip from vtip.43z.one'
  })
end

function M.setup() setup_basic() end

return M
