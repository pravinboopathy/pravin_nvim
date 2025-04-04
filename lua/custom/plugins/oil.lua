return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependencies
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
  config = function()
    require('oil').setup()

    -- Open parent directory in Oil
    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory with Oil' })

    -- Open Oil in a floating window
    vim.keymap.set('n', '<leader>-', function()
      require('oil').open_float()
    end, { desc = 'Open Oil in floating window' })
  end,
}
