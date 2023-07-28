local utils = require('userlib.runtime.utils')

return {
  {
    function()
      for name, _ in pairs(package.loaded) do
        if name:match('^plugins.') or name:match('^user.') or name:match('userlib.') then
          package.loaded[name] = nil
        end
      end

      dofile(vim.env.MYVIMRC)
      Ty.NOTIFY('nvimrc reloaded')
    end,
    description = 'Reload nvimrc',
  },
  {
    function()
      require('userlib.telescope.pickers').edit_neovim()
    end,
    description = "Edit Neovim dotfiles(nvimrc)",
  },
  {
    function() vim.cmd('e ' .. vim.fs.dirname(vim.fn.expand('$MYVIMRC')) .. '/lua/ty/contrib/editing/switch_rc.lua') end,
    description = 'Edit switch definitions',
  },
  -- dismiss notify
  {
    function() require('notify').dismiss() end,
    description = 'Dismiss notifications',
  },
  -- toggle light mode.
  {
    function() Ty.ToggleTheme() end,
    description = 'Toggle dark/light mode',
  },
  {
    function() require('userlib.lsp.fmt.autoformat').toggle() end,
    description = 'Toggle auto format',
  },
  {
    function() require('userlib.session').save_current_session() end,
    description = "[Session] Save current session",
  },
  {
    function() require('userlib.session').load_last_session() end,
    description = "[Session] Load last session",
  },
  {
    function() require('userlib.session').load_current_session() end,
    description = "[Session] Load current dir session",
  },

  {
    function() require('userlib.session').remove_current_sesion() end,
    description = "[Session] Remove current session",
  },
  {
    function() require('userlib.session').list_all_session() end,
    description = "[Session] List all session",
  },
  {
    function() require('userlib.telescope.pickers').project_files({ no_gitfiles = true }) end,
    description = "Telescope find project files (No Git)",
  },
  {
    itemgroup = "Navigation UI",
    funcs = {
      {
        function()
          require("harpoon.ui").toggle_quick_menu()
        end,
        description = "harpoon marks menu',"
      },
      {
        function()
          require('grapple').popup_tags()
        end,
        description = "grapple popup tags",
      }
    }
  },
  {
    function()
      utils.load_plugins('blackjack.nvim')
      vim.cmd('BlackJackNewGame')
    end,
    description = "New black jack game",
  },
  {
    function()
      utils.load_plugins('nvim-colorizer.lua')
      vim.cmd('ColorizerAttachToBuffer')
    end,
    description = 'Enable colorizer on buffer (color)',
  },
  {
    function()
      utils.load_plugins('nvim-colorizer.lua')
      vim.cmd('ColorizerToggle')
    end,
    description = 'Toggle colorizer',
  },
  {
    function()
      vim.ui.input({
        prompt = "Are you sure? (y/n)",
      }, function(input)
        if input ~= 'y' and input ~= 'Y' and input ~= 'yes' then
          return
        end
        vim.cmd("e!")
        vim.notify("Changes reverted")
      end)
    end,
    description = "Discard changes",
  },
  {
    function()
      vim.notify("Build start")
      if vim.loader then
        vim.loader.reset()
        vim.loader.disable()
      end
      vim.schedule(function()
        require("zenbones.shipwright").run()
        vim.notify("Build done")
      end)
    end,
    description = "Build zenbones",
  }
}
