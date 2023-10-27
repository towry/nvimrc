local M = {}

function M.custom_theme_wildcharm()
  --- custom wildcharm theme.
  vim.cmd([[hi! Visual guifg=#000000 guibg=#ffffff gui=NONE cterm=NONE]])
end

local is_setup_theme_done = false
function M.setup_theme()
  if is_setup_theme_done then return end
  local ok = pcall(vim.cmd, 'colorscheme ' .. vim.cfg.ui__theme_name)
  if ok then
    is_setup_theme_done = true
  else
    return
  end
  if type(M['custom_theme_' .. vim.cfg.ui__theme_name]) == 'function' then
    vim.schedule(M['custom_theme_' .. vim.cfg.ui__theme_name])
  end
end

M.setup = function()
  if vim.cfg.runtime__starts_in_buffer then M.setup_theme() end
end

return M