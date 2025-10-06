return {
  'nvim-neorg/neorg',
  lazy = false,
  version = '*',
  config = function()
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
        ['core.integrations.nvim-cmp'] = {},
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
