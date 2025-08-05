local agent_prompt = [[
1. When I ask to build a new feature, always provide a plan and pause for me to confirm.
2. When implementing a new multi-step plan, always validate unit tests and commit after each step.
3. When using Go, `make test` will run unit tests.
4. When using TypeScript, `yarn test` will run unit tests.
5. Prefer not to duplicate code and instead refactor if possible.
6. Prefer separating logically distinct code into different files.
]]

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
                default = 'claude-sonnet-4',
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = 'copilot',
          tools = {
            groups = {
              ['full_stack_dev'] = {
                -- overrides agent system_prompt
                system_prompt = agent_prompt,
              },
            },
          },
        },
        inline = {
          adapter = 'copilot',
          keymaps = {
            accept_change = {
              modes = { n = 'ca' },
              description = 'Accept the suggested change',
            },
            reject_change = {
              modes = { n = 'cr' },
              description = 'Reject the suggested change',
            },
          },
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
