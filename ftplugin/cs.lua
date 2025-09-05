-- ~/.config/nvim/ftplugin/cs.lua

-- debug log
vim.notify 'Loaded cs ftplugin'

-- Only apply to the current buffer
local map = function(keys, func, desc)
  vim.keymap.set('n', keys, func, { buffer = true, desc = desc })
end

-- Override keybindings (check for existence before mapping)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    -- vim.notify 'C# ftplugin LspAttach autocmd ran'
    local omnisharp_ext = require 'omnisharp_extended'
    vim.keymap.set('n', '<leader>gr', omnisharp_ext.telescope_lsp_references, { buffer = args.buf, desc = '[G]oto [R]eferences' })
    vim.keymap.set('n', '<leader>gd', omnisharp_ext.telescope_lsp_definition, { buffer = args.buf, desc = '[G]oto [D]efinition(OmniSharp Extended)' })
    vim.keymap.set('n', '<leader>gt', omnisharp_ext.telescope_lsp_type_definition, { buffer = args.buf, desc = '[G]oto [T]ype Definition' })
    vim.keymap.set('n', '<leader>gi', omnisharp_ext.telescope_lsp_implementation, { buffer = args.buf, desc = '[G]oto [I]mplementation' })
    vim.keymap.set('n', 'gd', omnisharp_ext.lsp_definition, { buffer = args.buf, desc = '[G]oto [D]efinition(OmniSharp Extended)' })
  end,
})
