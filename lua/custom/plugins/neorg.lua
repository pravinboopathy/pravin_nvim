return {
  'nvim-neorg/neorg',
  lazy = false,
  version = '*',
  config = function()
    -- lazy.nvim's rocks/hererocks build compiles tree-sitter-norg(-meta) into
    -- lazy-rocks/, but that location is never added to package.cpath, so
    -- neorg's own core.integrations.treesitter module (which looks parsers
    -- up via package.searchpath) can't find them and warns on every startup.
    for _, rock in ipairs { 'tree-sitter-norg', 'tree-sitter-norg-meta' } do
      package.cpath = package.cpath .. ';' .. vim.fn.expand('~/.local/share/nvim/lazy-rocks/' .. rock .. '/lib/lua/5.1/?.so')
    end

    require('neorg').setup {
      load = {
        ['core.defaults'] = {},
        ['core.concealer'] = {},
        ['core.dirman'] = {
          config = {
            workspaces = {
              notes = '~/notes',
            },
            default_workspace = 'notes',
          },
        },
        ['core.summary'] = {},
        ['core.export'] = {},
        ['core.export.markdown'] = {
          config = {
            extensions = 'all',
          },
        },
        ['core.journal'] = {
          config = {
            journal_folder = 'journal',
            strategy = 'flat',
            workspace = 'notes',
          },
        },
      },
    }
    vim.wo.foldlevel = 99
  end,
}
