-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- When use leader p in visual mode, delete highlighted content (not overwriting any registers) and paste over it
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Delete and paste without overwriting register' })

-- Deletes to _(discard) register
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { desc = 'Delete to the black hole register' })

-- Next greatest remap ever : asbjornHaland
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'Yank line to system clipboard' })

-- Format current buffer (file)
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format current buffer' })

-- Makes current file executable
vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true, desc = 'Make file executable' })

-- Clear highlighted text on search
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Example: Alt-based navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true, desc = 'Move to the left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true, desc = 'Move to the window below' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true, desc = 'Move to the window above' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true, desc = 'Move to the right window' })

-- Jump to first non empty space in the line
vim.keymap.set({ 'n', 'v' }, '<leader>b', '^', { noremap = true, silent = true })

-- Jump to last non empty space character in line
vim.keymap.set({ 'n', 'v' }, '<leader>e', 'g_', { noremap = true, silent = true })

-- Quickfix and Location List Key Mappings for Neovim
-- These mappings use Lua API for better maintainability

-- Quickfix Mappings
local quickfix_mappings = {
  { mode = 'n', lhs = '<leader>qo', rhs = ':copen<CR>', desc = 'Open Quickfix List' },
  { mode = 'n', lhs = '<leader>qc', rhs = ':cclose<CR>', desc = 'Close Quickfix List' },
  { mode = 'n', lhs = '<leader>qn', rhs = ':cnext<CR>zz', desc = 'Next Quickfix Item' },
  { mode = 'n', lhs = '<leader>qp', rhs = ':cprev<CR>zz', desc = 'Previous Quickfix Item' },
  { mode = 'n', lhs = '<leader>qf', rhs = ':cfirst<CR>', desc = 'First Quickfix Item' },
  { mode = 'n', lhs = '<leader>ql', rhs = ':clast<CR>', desc = 'Last Quickfix Item' },
  {
    mode = 'n',
    lhs = '<leader>qcl',
    rhs = function()
      vim.fn.setqflist {}
    end,
    desc = 'Clear Quickfix List',
  },
  { mode = 'n', lhs = '<leader>qt', rhs = ':cwindow<CR>', desc = 'Toggle Quickfix List' },
}

-- Location List Mappings
local location_list_mappings = {
  { mode = 'n', lhs = '<leader>lo', rhs = ':lopen<CR>', desc = 'Open Location List' },
  { mode = 'n', lhs = '<leader>lc', rhs = ':lclose<CR>', desc = 'Close Location List' },
  { mode = 'n', lhs = '<leader>ln', rhs = ':lnext<CR>zz', desc = 'Next Location List Item' },
  { mode = 'n', lhs = '<leader>lp', rhs = ':lprev<CR>zz', desc = 'Previous Location List Item' },
  { mode = 'n', lhs = '<leader>lt', rhs = ':lwindow<CR>', desc = 'Toggle Location List' },
}

-- Function to set key mappings
local function set_keymaps(mappings)
  for _, map in ipairs(mappings) do
    vim.keymap.set(map.mode, map.lhs, map.rhs, { desc = map.desc })
  end
end

-- Apply the mappings
set_keymaps(quickfix_mappings)
set_keymaps(location_list_mappings)

-- Notes:
-- Replace <leader> with your preferred leader key (e.g., ',' or ' ').
-- "zz" centers the cursor after jumping to the next/previous item.
-- Modify the mappings as per your workflow and preferences.

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
