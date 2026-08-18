return {
  'harrisoncramer/gitlab.nvim',
  enabled = false, -- requires a Go >=1.25.1 toolchain to build its companion binary; re-enable if you install one
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'sindrets/diffview.nvim',
    'stevearc/dressing.nvim', -- Recommended but not required. Better UI for pickers.
    'nvim-tree/nvim-web-devicons', -- Recommended but not required. Icons in discussion tree.
  },
  build = function()
    require('gitlab.server').build(true)
  end, -- Builds the Go binary
  config = function()
    require('gitlab').setup()
  end,
}
