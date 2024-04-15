if not vim.cfg then
  return
end

local au = require('userlib.runtime.au')

au.on_verylazy(function()
  ---- create abbreviations for command line.
  --- @param abbr string
  --- @param expand string|function
  local setca = function(abbr, expand)
    vim.keymap.set('ca', abbr, expand, { expr = type(expand) == 'function' and true or false })
  end

  setca('aw', 'wall')
  setca('avo', 'vertical Oil')
  setca('alp', 'Lazy profile')
  setca('ad', 'OverDispatch')
  setca('asb', 'ScratchBuffer')
  setca('ams', 'MakeSession')
  setca('als', 'LoadSession')
  --- name without ext
  setca('aname', function()
    return vim.fn.expand('%:t:r')
  end)
  setca('afile', function()
    return vim.fn.expand('%:t')
  end)
  setca('apath', function()
    return vim.fn.expand('%')
  end)
  --- expand to current file's dir
  vim.cmd.cabbr({ args = { '<expr>', '%%', "&filetype == 'oil' ? bufname('%')[6:] : expand('%:h')" } })
  setca('ats', 'TermSelect')
  -- find alt file and edit
  setca('altfind', function()
    local name = vim.fn.expand('%:t:r')
    return 'find ' .. name
  end)
  setca('ass', 'let @/=')
  if vim.cfg and vim.cfg.edit__use_coc then
    setca('acc', 'CocCommand')
  end
end)
