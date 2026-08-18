return {
  { -- Treesitter main module
    'nvim-treesitter/nvim-treesitter',
    branch = 'main', -- full rewrite: no more nvim-treesitter.configs, no lazy-loading
    lazy = false,
    build = ':TSUpdate',
    dependencies = {
      { -- Ensure Textobjects are installed
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        init = function()
          -- We define our own keymaps below; don't let the plugin add its own.
          vim.g.no_plugin_maps = true
        end,
      },
    },
    config = function()
      local ensure_installed = {
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
        -- norg / norg_meta: not in nvim-treesitter's parser registry on the
        -- `main` branch at all (install() just warns and skips them) — norg
        -- highlighting comes from neorg.lua's own package.cpath fix instead.
        'query',
        'vim',
        'vimdoc',
        'go',
        'python',
      }

      require('nvim-treesitter').install(ensure_installed)

      ---@param buf integer
      ---@param language string
      local function try_attach(buf, language)
        -- Check if a parser exists and load it.
        if not vim.treesitter.language.add(language) then
          return
        end

        -- Replaces highlight.enable = true.
        vim.treesitter.start(buf, language)

        -- Replaces indent.enable = true; falls back to Vim's built-in indent
        -- when a language has no indent query (this is what the old
        -- indent.disable = { 'ruby' } was approximating).
        local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil
        if has_indent_query then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      -- Replaces auto_install = true: install on demand for any filetype
      -- with an available parser, then attach highlighting + indent.
      local available_parsers = require('nvim-treesitter').get_available()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf, filetype = args.buf, args.match

          local language = vim.treesitter.language.get_lang(filetype)
          if not language then
            return
          end

          local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

          if vim.tbl_contains(installed_parsers, language) then
            try_attach(buf, language)
          elseif vim.tbl_contains(available_parsers, language) then
            require('nvim-treesitter').install(language):await(function()
              try_attach(buf, language)
            end)
          else
            try_attach(buf, language)
          end
        end,
      })

      -- Textobjects: new imperative API replaces the old declarative
      -- textobjects.select.keymaps table.
      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true,
          selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@function.outer'] = 'V',
            ['@class.outer'] = '<c-v>',
          },
          include_surrounding_whitespace = true,
        },
      }

      local select_textobject = require('nvim-treesitter-textobjects.select').select_textobject

      local textobject_keymaps = {
        af = { query = '@function.outer', desc = 'Select outer part of a function' },
        ['if'] = { query = '@function.inner', desc = 'Select inner part of a function' },
        ac = { query = '@class.outer', desc = 'Select outer part of a class' },
        ic = { query = '@class.inner', desc = 'Select inner part of a class region' },
      }
      for lhs, map in pairs(textobject_keymaps) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select_textobject(map.query, 'textobjects')
        end, { desc = map.desc })
      end

      -- Was query_group = 'locals' in the old declarative config.
      vim.keymap.set({ 'x', 'o' }, 'as', function()
        select_textobject('@local.scope', 'locals')
      end, { desc = 'Select language scope' })
    end,
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
