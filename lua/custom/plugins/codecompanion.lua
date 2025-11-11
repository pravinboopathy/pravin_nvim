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
        http = {
          claude = function()
            return require('codecompanion.adapters').extend('copilot', {
              name = 'claude', -- Give this adapter a different name to differentiate it from the default copilot adapter
              schema = {
                model = {
                  default = 'claude-sonnet-4.5',
                },
              },
            })
          end,
        },
        acp = {
          codex = function()
            return require('codecompanion.adapters').extend('codex', {
              defaults = {
                auth_method = 'chatgpt', -- "openai-api-key"|"codex-api-key"|"chatgpt"
              },
            })
          end,
        },
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
      },
      prompt_library = {
        ['refactor'] = {
          strategy = 'chat',
          description = 'Generate unit tests for the current files',
          opts = {
            is_default = true,
            is_slash_cmd = true,
            short_name = 'unit_test',
            adapter = {
              name = 'claude',
            },
          },
          prompts = { -- TODO: provide refactor as a tool to agent, and have it chain with re-running unit tests
            {
              role = 'user',
              content = [[
              Refactor the following code to align with best practices and principles outlined in the book Clean Code by Robert C. Martin. Focus on improving readability, maintainability, and efficiency while ensuring the following principles are applied:
              Refactor the code while preserving its original functionality
              ]],
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ['unit_test'] = {
          strategy = 'chat',
          description = 'Generate unit tests for the current files',
          opts = {
            is_default = true,
            is_slash_cmd = true,
            short_name = 'unit_test',
            adapter = {
              name = 'claude',
            },
          },
          context = {
            {
              type = 'file',
              path = { --TODO: update these file paths, survivor should be relative to main and need to clone tenuki-go
                '/Users/pboopath/cloudlab/apps/kepler/services/survivor/gprc_survivor_client/internal/probe/regex_test.go',
                '/Users/pboopath/cloudlab/apps/core/lib/tenuki-go/main/testutil/comparison.go',
                '/Users/pboopath/cloudlab/apps/core/lib/tenuki-go/main/testutil/error_handling.go',
              },
            },
          },
          prompts = {
            {
              role = 'user',
              content = [[When generating unit tests, follow the structure of regex_test. Importantly:
            1. Use table-driven tests.
            2. Use the map of name to test case structs
            3. Use testutil package whenever possible
            4. When naming variables representing expected output, use naming convention "exp{var}". Don't use "want{var}. For example, compare "expResp" against "gotResp"
            Also note, the import path for the testutil package is "go.eccp.epic.com/tenuki/testutil"]],
              opts = {
                contains_code = true,
              },
            },
          },
        },
        -- TODO: add prompt pre mr subimission that makes sure all exported structs are documented and all tests use conform to unit test expectations. Can use vectorcode for providing context
        ['ready_for_pqa'] = {
          strategy = 'chat',
          description = "Get's project in a state that is ready for PQA",
          opts = {
            is_default = true,
            is_slash_cmd = true,
            short_name = 'ready_for_pqa',
            adapter = {
              name = 'claude',
            },
          },
          context = {
            {
              type = 'file',
              path = { --TODO: update these file paths, survivor should be relative to main and need to clone tenuki-go
                '/Users/pboopath/cloudlab/apps/kepler/services/survivor/gprc_survivor_client/internal/probe/regex_test.go',
                '/Users/pboopath/cloudlab/apps/core/lib/tenuki-go/main/testutil/comparison.go',
                '/Users/pboopath/cloudlab/apps/core/lib/tenuki-go/main/testutil/error_handling.go',
              },
            },
          },
          prompts = {
            {
              role = 'user',
              content = [[
              TODO: add prompt, have agent run go over added code, point out any obvious refactors(->use refactor tool if accept refactor), remove any added code, then run make and make sure passes
              ]],
              opts = {
                contains_code = true,
              },
            },
          },
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
