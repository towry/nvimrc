vim.b.minianimate_disable = true
vim.opt.spell = false

local bufnr = vim.api.nvim_get_current_buf()
local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

set('n', '<S-q>', function()
  require('oil').close()
end, {
  desc = 'Close oil',
})
