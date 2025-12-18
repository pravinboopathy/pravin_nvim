-- Lua
return {
  -- Replace true-zen with zen-mode
  'folke/zen-mode.nvim',
  opts = {
    window = {
      -- adjust these to taste
      backdrop = 0.95,
      width = 0.6,  -- can be absolute number or float (percentage of width)
      height = 0.9, -- can be absolute number or float
      options = {
        signcolumn = "no",
        number = false,
        relativenumber = false,
        cursorline = false,
        cursorcolumn = false,
        foldcolumn = "0",
        list = false,
      },
    },
    plugins = {
      -- this is the tmux integration you had before
      tmux = { enabled = true },
      -- other optional integrations
      gitsigns = { enabled = true },
      twilight = { enabled = false }, -- if you use folke/twilight.nvim
    },
  },
  config = function(_, opts)
    require('zen-mode').setup(opts)
  end,
  keys = {
    {
      '<leader>zf',
      function() require('zen-mode').toggle() end,
      mode = 'n',
      desc = 'Focued mode (ZenMode)',
      noremap = true,
    },
  },
}
