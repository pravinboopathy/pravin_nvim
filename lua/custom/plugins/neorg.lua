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
              project_notes = '~/project_notes',
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
      },
    }
    vim.wo.foldlevel = 99
  end,
}
