local M = {}

--- wrap function for navigate lsp diagnostics, used by keymaps.
--- @param next boolean "next" or "prev"
--- @param severity string "ERROR", "WARN", "INFO", "HINT"
function M.diagnostic_goto(next, severity)
  local enable_lspasaga_jump = Ty.Config.navigate.enable_lspasaga_diagnostic_jump
  local has_lspsaga = enable_lspasaga_jump and require('ty.core.utils').has_plugin('lspsaga.nvim')

  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  local sev = severity and vim.diagnostic.severity[severity] or nil

  if has_lspsaga then
    local saga = require('lspsaga.diagnostic')
    if next then
      saga:goto_next({ severity = sev })
    else
      saga:goto_prev({ severity = sev })
    end
    return
  end

  go({ severity = sev })
end

function M.goto_definition_in_file(command) require('gtd').exec({ command = command or 'edit' }) end

function M.goto_definition()
  local has_lspsaga = require('ty.core.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    vim.cmd('Lspsaga goto_definition')
  else
    vim.lsp.buf.definition()
  end
end

function M.goto_type_definition()
  local has_lspsaga = require('ty.core.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    vim.cmd('Lspsaga goto_type_definition')
  else
    vim.lsp.buf.definition()
  end
end

function M.goto_code_references()
  local has_lspsaga = require('ty.core.utils').has_plugin('lspsaga.nvim')
  if has_lspsaga then
    vim.cmd('Lspsaga lsp_finder')
  else
    vim.lsp.buf.references()
  end
end

function M.jump_to_tag(target)
  local method_name = ({
        parent = 'jumpParent',
        next = 'jumpNextSibling',
        prev = 'jumpPrevSibling',
        child = 'jumpChild',
      })[target]
  require('jump-tag')[method_name]()
end

function M.portal_backward()
  local builtins = require('portal.builtin')
  local opts = {
    direction = 'backward',
    max_results = 2,
  }

  local jumplist = builtins.jumplist.query(opts)
  local harpoon = builtins.harpoon.query(opts)
  local grapples = builtins.grapple.query(opts)

  require('portal').tunnel({ harpoon, grapples, jumplist })
end

function M.portal_forward()
  local builtins = require('portal.builtin')
  local opts = {
    direction = 'forward',
    max_results = 2,
  }

  local jumplist = builtins.jumplist.query(opts)
  local harpoon = builtins.harpoon.query(opts)
  local grapples = builtins.grapple.query(opts)

  require('portal').tunnel({ harpoon, grapples, jumplist })
end

function M.next_unsaved_buf()
  return require('ty.contrib.navigate.buffer').next_unsaved_buf()
end

function M.prev_unsaved_buf()
  return require('ty.contrib.navigate.buffer').prev_unsaved_buf()
end

return M
