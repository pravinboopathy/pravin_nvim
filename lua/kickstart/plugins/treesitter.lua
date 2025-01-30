return {
  { -- Treesitter main module
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects', -- Ensure Textobjects are installed
    },
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'diff',
        'html',
        'javascript',
        'typescript',
        'lua',
        'luadoc',
        'json',
        'yaml',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'go',
        'python',
      },
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = { 'ruby' } },
      indent = { enable = true, disable = { 'ruby' } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<Leader>ss',
          node_incremental = '<Leader>si',
          scope_incremental = '<Leader>sc',
          node_decremental = '<Leader>sd',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
            ['as'] = { query = '@local.scope', query_group = 'locals', desc = 'Select language scope' },
          },
          selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@function.outer'] = 'V',
            ['@class.outer'] = '<c-v>',
          },
          include_surrounding_whitespace = true,
        },
        move = {
          enable = true,
          set_jumps = true, -- Save jumps in the jumplist (`<C-o>` to go back)
          goto_next_start = {
            [']f'] = '@function.outer',
            [']F'] = '@function.inner',
            [']c'] = '@class.outer',
            [']C'] = '@class.inner',
            [']l'] = '@loop.outer',
            [']b'] = '@block.outer',
            [']a'] = '@parameter.inner',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[F'] = '@function.inner',
            ['[c'] = '@class.outer',
            ['[C'] = '@class.inner',
            ['[l'] = '@loop.outer',
            ['[b'] = '@block.outer',
            ['[a'] = '@parameter.inner',
          },
          goto_next_end = {
            [']e'] = '@function.outer',
            [']E'] = '@class.outer',
          },
          goto_previous_end = {
            ['[e'] = '@function.outer',
            ['[E'] = '@class.outer',
          },
        },
      },
    },
  },
  { -- Treesitter Context
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      enable = true,
      max_lines = 0,
      trim_scope = 'outer',
      mode = 'cursor',
      separator = nil,
    },
  },
  { -- Register Treesitter movements in which-key
    'folke/which-key.nvim',
    config = function()
      local wk = require 'which-key'
      wk.register {
        [']'] = {
          name = 'Next',
          f = { ':TSTextobjectGotoNextStart @function.outer<CR>', 'Next function' },
          F = { ':TSTextobjectGotoNextStart @function.inner<CR>', 'Next function (inner)' },
          c = { ':TSTextobjectGotoNextStart @class.outer<CR>', 'Next class' },
          C = { ':TSTextobjectGotoNextStart @class.inner<CR>', 'Next class (inner)' },
          l = { ':TSTextobjectGotoNextStart @loop.outer<CR>', 'Next loop' },
          b = { ':TSTextobjectGotoNextStart @block.outer<CR>', 'Next block' },
          a = { ':TSTextobjectGotoNextStart @parameter.inner<CR>', 'Next function argument' },
          e = { ':TSTextobjectGotoNextEnd @function.outer<CR>', 'Next function end' },
          E = { ':TSTextobjectGotoNextEnd @class.outer<CR>', 'Next class end' },
        },
        ['['] = {
          name = 'Previous',
          f = { ':TSTextobjectGotoPreviousStart @function.outer<CR>', 'Previous function' },
          F = { ':TSTextobjectGotoPreviousStart @function.inner<CR>', 'Previous function (inner)' },
          c = { ':TSTextobjectGotoPreviousStart @class.outer<CR>', 'Previous class' },
          C = { ':TSTextobjectGotoPreviousStart @class.inner<CR>', 'Previous class (inner)' },
          l = { ':TSTextobjectGotoPreviousStart @loop.outer<CR>', 'Previous loop' },
          b = { ':TSTextobjectGotoPreviousStart @block.outer<CR>', 'Previous block' },
          a = { ':TSTextobjectGotoPreviousStart @parameter.inner<CR>', 'Previous function argument' },
          e = { ':TSTextobjectGotoPreviousEnd @function.outer<CR>', 'Previous function end' },
          E = { ':TSTextobjectGotoPreviousEnd @class.outer<CR>', 'Previous class end' },
        },
      }
    end,
  },
}
