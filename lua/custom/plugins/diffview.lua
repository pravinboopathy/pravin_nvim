return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local actions = require 'diffview.actions' -- Ensure actions are properly required

    require('diffview').setup {
      view = {
        default = {
          layout = 'diff2_horizontal', -- Default layout for diffs
        },
        merge_tool = {
          layout = 'diff3_mixed', -- Local (left), Remote (right), MERGED (below)
          disable_diagnostics = true, -- Disable diagnostics in conflict buffers
        },
        file_history = {
          layout = 'diff2_horizontal', -- Keeps history layout consistent
        },
      },
      keymaps = {
        disable_defaults = false, -- Disable the default keymaps
        view = { -- Within a diff
          ['g<C-x>'] = actions.cycle_layout, -- Cycle through available layouts
          ['[x'] = actions.prev_conflict, -- Jump to previous conflict
          [']x'] = actions.next_conflict, -- Jump to next conflict
          { 'n', '<leader>co', actions.conflict_choose 'ours', { desc = 'Choose the OURS version of a conflict' } },
          { 'n', '<leader>ct', actions.conflict_choose 'theirs', { desc = 'Choose the THEIRS version of a conflict' } },
          { 'n', '<leader>cb', actions.conflict_choose 'base', { desc = 'Choose the BASE version of a conflict' } },
          { 'n', '<leader>ca', actions.conflict_choose 'all', { desc = 'Choose all the versions of a conflict' } },
          { 'n', 'dx', actions.conflict_choose 'none', { desc = 'Delete the conflict region' } },
          { 'n', '<leader>cO', actions.conflict_choose_all 'ours', { desc = 'Choose OURS for the whole file' } },
          { 'n', '<leader>cT', actions.conflict_choose_all 'theirs', { desc = 'Choose THEIRS for the whole file' } },
          { 'n', '<leader>cB', actions.conflict_choose_all 'base', { desc = 'Choose BASE for the whole file' } },
          { 'n', '<leader>cA', actions.conflict_choose_all 'all', { desc = 'Choose ALL for the whole file' } },
          { 'n', 'dX', actions.conflict_choose_all 'none', { desc = 'Delete all conflict regions' } },
        },
        diff3 = {
          { 'n', 'g?', actions.help { 'view', 'diff3' }, { desc = 'Open the help panel' } },
        },
        file_panel = {
          ['g<C-x>'] = actions.cycle_layout,
          ['[x'] = actions.prev_conflict,
          [']x'] = actions.next_conflict,
        },
        file_history_panel = {
          ['g<C-x>'] = actions.cycle_layout,
        },
      },
    }
  end,
  -- Lazy-load on specific commands
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles' },
}
