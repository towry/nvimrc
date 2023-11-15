local plug = require('userlib.runtime.pack').plug
local utils = require('userlib.runtime.utils')
local au = require('userlib.runtime.au')
local git_branch_icon = ' '
local enable_lualine = false

local function is_treesitter()
  local bufnr = vim.api.nvim_get_current_buf()
  return vim.treesitter.highlighter.active[bufnr] ~= nil
end

local git_status_source = function()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

local git_branch = {
  'FugitiveHead',
  icon = git_branch_icon,
}

local tabs_nrto_icons = {
  ['1'] = '❶ ',
  ['2'] = '❷ ',
  ['3'] = '❸ ',
  ['4'] = '❹ ',
  ['5'] = '❺ ',
  ['6'] = '❻ ',
  ['7'] = '❼ ',
  ['8'] = '❽ ',
  ['9'] = '❾ ',
  ['10'] = '❿ ',
}
local cwd_component = {
  function() return vim.t.cwd_short or vim.cfg.runtime__starts_cwd_short end,
  icon = ' ',
}
local tabs_component = {
  'tabs',
  max_length = vim.o.columns / 2,
  mode = 1,
  use_mode_colors = true,
  draw_empty = false,
  -- tabs_color = {
  --   active = { fg = 'Green', gui = 'bold,underline' },
  --   inactive = { fg = 'Comment' },
  -- },
  cond = function() return vim.fn.tabpagenr('$') > 1 end,
  fmt = function(name, context)
    local cwd = vim.t[context.tabnr].cwd
    if cwd then
      cwd = vim.fn.fnamemodify(cwd, ':t')
    elseif not cwd then
      cwd = name
    end
    return string.format('%s%s', context.tabnr, cwd ~= '' and ':' .. cwd or '')
  end,
}

plug({
  'nvim-lualine/lualine.nvim',
  enabled = enable_lualine,
  cond = not vim.cfg.runtime__starts_as_gittool,
  dependencies = {
    {
      -- 'pze/lualine-copilot',
      'ofseed/copilot-status.nvim',
      dev = false,
      enabled = true,
    },
    'tpope/vim-fugitive',
  },
  event = { 'User LazyUIEnterOncePost', 'User OnLeaveDashboard' },
  -- event = 'BufReadPre',
  config = function()
    require('user.config.options').setup_statusline()
    local auto_format_disabled = require('userlib.lsp.servers.null_ls.autoformat').disabled
    local format_utils = require('userlib.lsp.servers.null_ls.fmt')
    -- local Buffer               = require('userlib.runtime.buffer')
    local terms = require('userlib.statusline.lualine.terminal_component')

    local spectre_extension = {
      sections = {
        lualine_a = { 'mode', tabs_component },
      },
      filetypes = { 'spectre_panel' },
    }
    local dashboard_extension = {
      sections = {
        lualine_a = {},
        lualine_b = {
          cwd_component,
          git_branch,
        },
        lualine_c = {
          -- tabs_component,
        },
      },
      winbar = {},
      filetypes = { 'starter', 'alpha' },
    }
    local empty_buffer_extension = {
      sections = {
        lualine_a = {
          tabs_component,
        },
        lualine_c = {
          {
            'diff',
            source = git_status_source,
          },
        }
      },
      winbar = {
        lualine_a = {
          function()
            return '  Hello Towry!'
          end,
          cwd_component,
          git_branch,
        },
      },
      filetypes = { '' },
    }
    local overseer_extension = {
      tabline = {
        lualine_a = {
          function()
            return 'Overseer list'
          end,
        }
      },
      filetypes = { 'OverseerList' },
    }
    local toggleterm_extension = {
      tabline = {},
      sections = {
        lualine_a = {
          'mode',
          {
            terms,
          },
        },
        lualine_c = {
          -- tabs_component,
        },
      },
      filetypes = { 'toggleterm' },
    }
    local present, lualine = pcall(require, 'lualine')

    if not present then
      Ty.NOTIFY('lualine not installed')
      return
    end

    lualine.setup({
      extensions = {
        spectre_extension,
        dashboard_extension,
        toggleterm_extension,
        overseer_extension,
        empty_buffer_extension,
        'neo-tree',
        'quickfix',
      },
      options = {
        theme = vim.cfg.workbench__lualine_theme,
        globalstatus = true,
        component_separators = '│',
        section_separators = { left = '', right = '' },
        disabled_filetypes = { winbar = vim.cfg.misc__ft_exclude, statusline = { 'dashboard', 'lazy', 'alpha' } },
      },
      winbar = {
        lualine_a = {
          {
            function()
              local cwd = vim.fn.fnamemodify(vim.b.project_nvim_cwd or vim.uv.cwd(), ':t')
              return cwd
            end,
            icon = '󰉋 '
          },
          {
            'filename',
            file_status = true,
            path = 1,
            fmt = function(name)
              if name == '[No Name]' then return '' end
              local bufnr = vim.fn.bufnr('%')
              if vim.b[bufnr].relative_path then
                name = vim.b[bufnr].relative_path
              end
              local winindex = vim.fn.win_id2win(vim.fn.win_getid())
              return string.format('%s.%s#%s', winindex, bufnr, name)
            end
          },

        }
      },
      inactive_winbar = {
        lualine_a = {
          {
            function()
              local cwd = vim.fn.fnamemodify(vim.b.project_nvim_cwd or vim.uv.cwd(), ':t')
              return cwd
            end,
            icon = '󰉋 '
          },
          {
            'filename',
            file_status = true,
            path = 1,
            fmt = function(name)
              local bufnr = vim.fn.bufnr('%')
              if vim.b[bufnr].relative_path then
                name = vim.b[bufnr].relative_path
              end
              local winindex = vim.fn.win_id2win(vim.fn.win_getid())
              return string.format('%s.%s#%s', winindex, bufnr, name)
            end
          },
        }
      },
      sections = {
        lualine_a = {
          { 'mode', fmt = function(str) return str:sub(1, 1) end },
          git_branch,
          tabs_component,
        },
        lualine_b = {
          {
            function()
              local idx = require('harpoon.mark').status()
              return idx
            end,
            cond = function()
              local harpoon_has = utils.pkg_loaded('harpoon')
              if not harpoon_has then return false end
              local idx = require('harpoon.mark').status()
              return idx and idx ~= ''
            end,
            icon = {
              '',
              color = {
                fg = 'red',
              },
            },
          },
        },
        lualine_c = {
          {
            'diagnostics',
            update_in_insert = false,
            symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
            cond = function()
              return vim.b.diagnostic_disable ~= true
            end
          },
          {
            'diff',
            source = git_status_source,
          },
        },
        lualine_x = {
          'searchcount',
          -- copilot status
          -- require('copilot_status').status_string,
          {
            'copilot',
          },
          {
            function()
              return ''
            end,
            name = "overseer-placeholder"
          },
          {
            terms,
          },
          {
            'encoding',
            cond = function() return vim.opt.fileencoding and vim.opt.fileencoding:get() ~= 'utf-8' end,
          },
          {
            function()
              local ret = vim.trim(vim.fn['codeium#GetStatusString']() or '')
              if ret == '*' then
                return '󱥸 '
              elseif ret == '0' then
                return ' '
              elseif ret ~= '' then
                return ret
              else
                return '󰛿 '
              end
            end,
            cond = function() return vim.cfg.plug__enable_codeium_vim end,
          },
          {
            function()
              local icon = '󰎟 '
              if auto_format_disabled(0) then
                icon = '󰙧 '
              end
              local ftr_name, impl_ftr_name = format_utils.current_formatter_name(0)
              if not ftr_name and not impl_ftr_name then
                return ''
              end
              return string.format('%s%s', icon, impl_ftr_name or ftr_name)
            end,
          },
          --- dap
          {
            function() return '  ' .. require('dap').status() end,
            cond = function() return package.loaded['dap'] and require('dap').status() ~= '' end,
            color = utils.fg('Debug'),
          },
          {
            'fileformat',
            cond = function() return not vim.tbl_contains({ 'unix', 'mac' }, vim.bo.fileformat) end,
          },
          {
            'filetype',
            icon = { align = 'left' },
            colored = false,
            icon_only = false,
          },
        },
        lualine_y = {
          'filesize',
        },
        lualine_z = {
          {
            function()
              if is_treesitter() then return '' end
              return '󰐆'
            end,
          },
          {
            function()
              if vim.diagnostic.is_disabled() then return '' end
              return ''
            end,
            cond = function()
              return vim.diagnostic.is_disabled()
            end,
          },
          {
            function()
              return vim.cfg.runtime__starts_cwd_short
            end,
            icon = ' '
          }
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { '' },
        -- lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
})

plug({
  --- Copied from stevearc's dotfiles
  ---@see https://github.com/stevearc/dotfiles/blob/860e18ee85d30a72cea5a51acd9983830259075e/.config/nvim/lua/plugins/heirline.lua#L4
  "rebelot/heirline.nvim",
  event = 'VeryLazy',
  cond = not vim.cfg.runtime__starts_as_gittool,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local comp = require('userlib.statusline.heirline.components')
    local heirline_utils = require('heirline.utils')

    require("heirline").load_colors(comp.setup_colors())
    local aug = vim.api.nvim_create_augroup("Heirline", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      desc = "Update Heirline colors",
      group = aug,
      callback = function()
        local colors = comp.setup_colors()
        heirline_utils.on_colorscheme(colors)
      end,
    })
    require("heirline").setup({
      winbar = {
        comp.DirAndFileName,
      },
      -- mode
      -- branch
      -- harpoon
      -- tabs
      -- lsp diagnostics
      -- git changes
      -- padding
      -- copilot
      -- formatter name
      -- filetype
      -- filesize
      -- root folder
      statusline = heirline_utils.insert(
        {
          static = comp.stl_static,
          hl = { bg = "bg" },
        },
        comp.ViMode,
        comp.lpad(comp.Branch),
        comp.lpad(comp.ProfileRecording),
        comp.lpad(comp.Harpoon),
        comp.lpad(comp.LSPActive),
        comp.lpad(require('userlib.statusline.heirline.component_diagnostic')),
        require("userlib.statusline.heirline").left_components,
        { provider = "%=" },
        comp.lpad(comp.Tabs),
        { provider = "%=" },
        require("userlib.statusline.heirline").right_components,
        comp.rpad(comp.Copilot),
        comp.rpad(comp.Overseer),
        comp.rpad(comp.LspFormatter),
        comp.rpad(comp.FileType),
        comp.rpad(comp.DiagnosticsDisabled),
        comp.rpad(comp.WorkspaceRoot)
      -- comp.Ruler
      ),

      opts = {
        disable_winbar_cb = function(args)
          local buf = args.buf
          local ignore_buftype = vim.tbl_contains(vim.cfg.misc__buf_exclude, vim.bo[buf].buftype)
          local filetype = vim.bo[buf].filetype
          local ignore_filetype = filetype == "fugitive" or filetype == "qf" or filetype:match("^git")
          local is_float = vim.api.nvim_win_get_config(0).relative ~= ""
          return ignore_buftype or ignore_filetype or is_float
        end,
      },
    })

    vim.api.nvim_create_user_command(
      "HeirlineResetStatusline",
      function() vim.o.statusline = "%{%v:lua.require'heirline'.eval_statusline()%}" end,
      {}
    )
    -- Because heirline is lazy loaded, we need to manually set the winbar on startup
    vim.opt_local.winbar = "%{%v:lua.require'heirline'.eval_winbar()%}"
  end
})
