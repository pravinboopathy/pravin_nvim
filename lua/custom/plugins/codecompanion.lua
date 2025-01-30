return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('codecompanion').setup {
      strategies = {
        chat = {
          adapter = 'copilot',
        },
        inline = {
          adapter = 'copilot',
        },
        agent = {
          adapter = 'copilot',
        },
      },
    }
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'codecompanion',
      callback = function()
        vim.defer_fn(function()
          vim.api.nvim_buf_set_keymap(0, 'i', '<C-c>', '<Esc>', { noremap = true, silent = true })
        end, 50) -- Delay for 50ms to allow the filetype to load
      end,
    })
    vim.keymap.set({ 'n', 'v' }, '<leader>cc', ':CodeCompanionChat<CR>', { noremap = true, silent = true })
    vim.keymap.set({ 'n', 'v' }, '<leader>ci', ':CodeCompanion<CR>', { noremap = true, silent = true })
  end,
}
