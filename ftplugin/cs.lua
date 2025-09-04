-- ~/.config/nvim/ftplugin/cs.lua

-- debug log
vim.notify 'Loaded cs ftplugin'

-- Only apply to the current buffer
local map = function(keys, func, desc)
  vim.keymap.set('n', keys, func, { buffer = true, desc = desc })
end

-- Import omnisharp extension module safely
local ok, omnisharp_ext = pcall(require, 'omnisharp_extended')
if not ok or type(omnisharp_ext) ~= 'table' then
  return
end

-- Override keybindings (check for existence before mapping)
if type(omnisharp_ext.telescope_lsp_references) == 'function' then
  map('<leader>gr', omnisharp_ext.telescope_lsp_references, '[G]oto [R]eferences')
end

if type(omnisharp_ext.telescope_lsp_definition) == 'function' then
  map('<leader>gd', function()
    omnisharp_ext.telescope_lsp_definition { jump_type = 'vsplit' }
  end, '[G]oto [D]efinition (vsplit)')
end

if type(omnisharp_ext.telescope_lsp_type_definition) == 'function' then
  map('<leader>gt', omnisharp_ext.telescope_lsp_type_definition, '[G]oto [T]ype Definition')
end

if type(omnisharp_ext.telescope_lsp_implementation) == 'function' then
  map('<leader>gi', omnisharp_ext.telescope_lsp_implementation, '[G]oto [I]mplementation')
end
