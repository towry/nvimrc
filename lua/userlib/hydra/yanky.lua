local M = {}

local yanky_hydra = nil

M.open_yanky_ring_hydra = function()
  local ok, Hydra = pcall(require, 'hydra')
  if not ok then return end

  if yanky_hydra == nil then
    yanky_hydra = Hydra({
      name = 'Yank ring',
      mode = 'n',
      heads = {
        { "p", "<Plug>(YankyPutAfter)", { desc = "After" } },
        { "P", "<Plug>(YankyPutBefore)", { desc = "Before" } },
        { "<C-n>", "<Plug>(YankyCycleForward)", { private = true, desc = "↓" } },
        { "<C-p>", "<Plug>(YankyCycleBackward)", { private = true, desc = "↑" } },
      }
    })
  end

  yanky_hydra:activate()
end

return M
