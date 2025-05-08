return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('codecompanion').setup {
      adapters = {
        copilot_agent = function()
          return require('codecompanion.adapters').extend('copilot', {
            name = 'copilot_agent', -- Give this adapter a different name to differentiate it from the default copilot adapter
            schema = {
              model = {
                default = 'claude-3.7-sonnet-thought',
              },
            },
          })
        end,
        copilot_chat = function()
          return require('codecompanion.adapters').extend('copilot', {
            name = 'copilot',
            schema = {
              model = {
                default = 'gpt-4.1',
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = 'copilot_chat',
        },
        inline = {
          adapter = 'copilot_chat',
        },
        agent = {
          adapter = 'copilot_agent',
        },
      },
      extensions = {
        vectorcode = {
          opts = {
            add_tool = true,
          },
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
