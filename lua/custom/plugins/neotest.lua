return {
  -- Neotest setup
  {
    'nvim-neotest/neotest',
    event = 'VeryLazy',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-plenary',
      'nvim-neotest/neotest-vim-test',

      {
        'fredrikaverpil/neotest-golang',
        ft = 'go', -- Lazy load only when editing Go files
        dependencies = {
          {
            'leoluz/nvim-dap-go',
            opts = {},
          },
        },
        branch = 'main',
      },
      {
        'Issafalcon/neotest-dotnet',
        ft = { 'cs', 'fs', 'vb' }, -- Lazy load for C#, F#, VB files
        branch = 'main',
      },
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      opts.adapters['neotest-golang'] = {
        go_test_args = { '-v', '-race', '-coverprofile=coverage.out' },
        concurrent = true, -- Run tests in parallel
      }
      opts.adapters['neotest-dotnet'] = {
        -- Tell neotest-dotnet to use either solution (requires .sln file) or project (requires .csproj or .fsproj file) as project root
        -- Note: If neovim is opened from the solution root, using the 'project' setting may sometimes find all nested projects, however,
        --       to locate all test projects in the solution more reliably (if a .sln file is present) then 'solution' is better.
        discovery_root = 'solution',
        dotnet_additional_args = {
          '--verbosity detailed',
        },
        dap = {
          -- Extra arguments for nvim-dap configuration
          -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
          args = { justMyCode = false },
          -- Enter the name of your dap adapter, the default value is netcoredbg
          adapter_name = 'netcoredbg',
        },
      }
      opts.running = { concurrent = true } -- Ensures multiple tests run in parallel
      opts.status = { virtual_text = false } -- Reduce UI updates
      opts.output = { open_on_run = false } -- Prevent auto-opening output
    end,
    config = function(_, opts)
      local neotest = require 'neotest'
      local adapters = {}

      -- Efficiently load adapters
      for name, config in pairs(opts.adapters or {}) do
        if config ~= false then
          local adapter = require(name)
          if type(config) == 'table' and not vim.tbl_isempty(config) then
            if adapter.setup then
              adapter.setup(config)
            else
              adapter(config)
            end
          end
          table.insert(adapters, adapter)
        end
      end

      opts.adapters = adapters
      neotest.setup(opts)
    end,
    keys = {
      {
        '<leader>ta',
        function()
          require('neotest').run.attach()
        end,
        desc = '[t]est [a]ttach',
      },
      {
        '<leader>tf',
        function()
          require('neotest').run.run(vim.fn.expand '%')
        end,
        desc = '[t]est run [f]ile',
      },
      {
        '<leader>tA',
        function()
          require('neotest').run.run(vim.uv.cwd())
        end,
        desc = '[t]est [A]ll files',
      },
      {
        '<leader>tS',
        function()
          require('neotest').run.run { suite = true }
        end,
        desc = '[t]est [S]uite',
      },
      {
        '<leader>tn',
        function()
          require('neotest').run.run()
        end,
        desc = '[t]est [n]earest',
      },
      {
        '<leader>tl',
        function()
          require('neotest').run.run_last()
        end,
        desc = '[t]est [l]ast',
      },
      {
        '<leader>ts',
        function()
          require('neotest').summary.toggle()
        end,
        desc = '[t]est [s]ummary',
      },
      {
        '<leader>to',
        function()
          require('neotest').output.open { enter = true, auto_close = true }
        end,
        desc = '[t]est [o]utput',
      },
      {
        '<leader>tO',
        function()
          require('neotest').output_panel.toggle()
        end,
        desc = '[t]est [O]utput panel',
      },
      {
        '<leader>tt',
        function()
          require('neotest').run.stop()
        end,
        desc = '[t]est [t]erminate',
      },
      {
        '<leader>td',
        function()
          require('neotest').run.run { strategy = 'dap' }
        end,
        desc = 'Debug nearest test',
      },
      {
        '<leader>tD',
        function()
          require('neotest').run.run { vim.fn.expand '%', strategy = 'dap' }
        end,
        desc = 'Debug current file',
      },
    },
  },

  -- DAP setup (debugging)
  {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    keys = {
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'toggle [d]ebug [b]reakpoint',
      },
      {
        '<leader>dB',
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = '[d]ebug [B]reakpoint',
      },
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        desc = '[d]ebug [c]ontinue',
      },
      {
        '<leader>do',
        function()
          require('dap').step_over()
        end,
        desc = '[d]ebug step [o]ver',
      },
      {
        '<leader>dO',
        function()
          require('dap').step_out()
        end,
        desc = '[d]ebug step [O]ut',
      },
      {
        '<leader>di',
        function()
          require('dap').step_into()
        end,
        desc = '[d]ebug [i]nto',
      },
      {
        '<leader>dp',
        function()
          require('dap').pause()
        end,
        desc = '[d]ebug [p]ause',
      },
      {
        '<leader>dr',
        function()
          require('dap').repl.toggle()
        end,
        desc = '[d]ebug [r]epl',
      },
      {
        '<leader>dt',
        function()
          require('dap').terminate()
        end,
        desc = '[d]ebug [t]erminate',
      },
    },
  },

  -- DAP UI setup
  {
    'rcarriga/nvim-dap-ui',
    event = 'VeryLazy',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'mfussenegger/nvim-dap',
    },
    opts = {},
    config = function(_, opts)
      local dap, dapui = require 'dap', require 'dapui'
      dapui.setup(opts)

      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end,
    keys = {
      {
        '<leader>du',
        function()
          require('dapui').toggle()
        end,
        desc = '[d]ap [u]i',
      },
      {
        '<leader>de',
        function()
          require('dapui').eval()
        end,
        desc = '[d]ap [e]val',
      },
    },
  },

  -- DAP Virtual Text (Inline Debugging)
  { 'theHamsta/nvim-dap-virtual-text', opts = {} },
}
