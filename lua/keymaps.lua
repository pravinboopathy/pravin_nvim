-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- when use leader p in visual mode, delete highlighted content(not overwriting an registers) and pastes over it
vim.keymap.set('x', '<leader>p', [["_dP]])

-- deletes to _(discard) register
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d')

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]])
vim.keymap.set('n', '<leader>Y', [["+Y]])

-- format current buffer(file)
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)

-- makes current file executable
vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true })

-- clear highlighted text on search
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Example: Alt-based navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
