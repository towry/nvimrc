--[[
  @usage:
  ```lua
  local pack = require("ty.core.pack").editing
  pack({
    "folke/lazy.nvim",
    Feature = "format",
    lazy = true,
  })
  ```
]]
--
local uv, api, fn = vim.loop, vim.api, vim.fn
local config = require('ty.core.config')
local utils = require('ty.core.utils')
---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack

local Spec = {
  ImportConfig = 'ImportConfig',
  Feature = 'Feature',
  ImportOption = 'ImportOption',
  ImportInit = 'ImportInit',
}

if _G.cachedPack ~= nil then return _G.cachedPack end

local pack = {
  repos = {},
  initd = {},
}

local lazy_opts = {
  -- lockfile = self.path_helper.join(self.data_path, 'lazy-lock.json'),
  dev = {
    path = '~/workspace/git-repos',
    fallback = true,
  },
  concurrency = 3,
  install = { colorscheme = { config.ui.theme.colorscheme } },
  checker = { enabled = false },
  defaults = { lazy = true },
  change_detection = {
    enabled = false,
  },
  git = {
    timeout = 120,
    url_format = 'https://ghproxy.com/https://github.com/%s',
  },
  ui = {
    icons = {
      lazy = ' ',
      plugin = ' ',
    },
  },
  custom_keys = {
    -- open lazygit log
    ['<localleader>l'] = function(plugin)
      require('lazy.util').float_term({ 'lazygit', 'log' }, {
        cwd = plugin.dir,
      })
    end,
    -- open a terminal for the plugin dir
    ['<localleader>t'] = function(plugin)
      require('lazy.util').float_term(nil, {
        cwd = plugin.dir,
      })
    end,
  },
  readme = {
    enabled = false,
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      -- https://github.com/neovim/neovim/tree/master/runtime/plugin
      disabled_plugins = {
        'gzip',
        'man',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
        -- for downloading spell files.
        'spellfile_plugin',
      },
    },
  },
}

function pack:load_modules_packages()
  local specs = require('ty.startup.repos')
  local plugins_initd = require('ty.startup.initd.plugins')
  -- specs is dict with { 'scope': list of plugins }
  for scope, plugins in pairs(specs) do
    local scoped_initd = type(plugins_initd[scope]) == 'function' and plugins_initd[scope]() or {}
    if scoped_initd.init then table.insert(pack.initd, scoped_initd.init) end

    for _, repo in ipairs(plugins) do
      if type(repo[Spec.ImportConfig]) == 'string' and repo.config == nil then
        repo.config = function(...)
          local args = ...
          utils.try(function()
            local is_ok, rc = pcall(require, 'ty.contrib.' .. scope .. '.package_rc')
            if not is_ok then
              print('package rc not found for ' .. scope)
              return
            end
            local setup_method = rc['setup_' .. repo[Spec.ImportConfig]]
            if type(setup_method) == 'function' then
              setup_method(unpack(args))
            else
              error('invalid package ImportConfig for ' .. repo[Spec.ImportConfig])
            end
          end)
        end
      end
      -- load opts.
      if type(repo[Spec.ImportOption]) == 'string' and repo.opts == nil then
        repo.opts = function()
          return require('ty.contrib.' .. scope .. '.package_rc')['option_' .. repo[Spec.ImportOption]]
        end
      end
      -- load init.
      if type(repo[Spec.ImportInit]) == 'string' and repo.init == nil and scoped_initd[repo[Spec.ImportInit]] then
        repo.init = scoped_initd[repo[Spec.ImportInit]]
      end
      -- insert
      table.insert(pack.repos, repo)
    end
  end
end

function pack:setup()
  self.path_helper = require('ty.core.path')
  self.data_path = vim.fn.stdpath('data')
  self.config_path = vim.fn.stdpath('config')

  local lazy_path = self.path_helper.join(self.data_path, 'lazy', 'lazy.nvim')
  local state = uv.fs_stat(lazy_path)
  if not state then
    local cmd = '!git clone https://github.com/folke/lazy.nvim ' .. lazy_path
    api.nvim_command(cmd)
  end
  vim.opt.runtimepath:prepend(lazy_path)
  local lazy = require('lazy')

  self:load_modules_packages()
  vim.api.nvim_create_autocmd('User', {
    group = vim.api.nvim_create_augroup('init_after_lazy_done', { clear = true }),
    pattern = 'LazyDone',
    callback = function()
      for _, init in ipairs(pack.initd) do
        init()
      end
    end,
  })
  lazy.setup(self.repos, lazy_opts)
  self.repos = nil
end

function pack.package(repo) table.insert(pack.repos, repo) end

--- load plugin.
pack.load = function(...) return require('lazy').load(...) end

-- set __index on pack, so we use access pack.xxx, we take xxx as scope and
-- return pack.contrib(xxx).
setmetatable(pack, {
  __index = function(_, key) return pack.contrib(key) end,
})

_G.cachedPack = pack

return pack
