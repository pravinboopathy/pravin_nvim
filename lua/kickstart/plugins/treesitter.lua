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
      max_lines = 5,
      trim_scope = 'outer',
      mode = 'cursor',
      separator = nil,
    },
  },
}
