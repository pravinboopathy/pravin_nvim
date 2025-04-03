-- In your Neovim config (init.lua or a plugin file)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf', -- quickfix filetype
  callback = function()
    vim.opt_local.number = true -- show absolute line numbers
    vim.opt_local.relativenumber = false -- disable relative line numbers
  end,
})
