-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

do --- LazyVim Options
  vim.g.lazyvim_picker = 'fzf'
end

do --- User Custom Options
  ---@type "clue" | "whichkey"
  vim.g.cfg_keymap_hint_helper = 'clue'
  ---@type "single" | "rounded" | "double" | "shadow"
  vim.g.cfg_border_style = 'single'
  ---@type {git: boolean}
  vim.g.cfg_inside = setmetatable({}, {
    __index = function(_, key)
      local v = require('v')
      if key == 'git' then
        v.git_is_using_nvim_as_tool()
      end
    end,
  })
  vim.g.cfg_resize_steps = 10
end

--- ======================================
local o = vim.opt
local g = vim.g

g.mapleader = ' '
g.maplocalleader = ','
o.autowrite = true
--- Make sure path working correctly in nix env
if vim.o.shell and vim.o.shell:find('fish') then
  o.shellcmdflag = ('--init-command="set PATH %s" -Pc'):format(vim.env.PATH)
end
o.startofline = false -- cursor start of line when scroll
pcall(function()
  -- NOTE: unload is experimental
  o.jumpoptions = 'stack,view,unload'
end)