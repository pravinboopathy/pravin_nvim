local M = {}

function M.export(opts)
  opts = opts or {}
  local date = opts.date or os.date('%Y-%m-%d')
  local output_path = opts.output or ('agenda/' .. date .. '.org')

  -- Configure for day view
  local cfg = require('orgmode.config')
  local orig_span = cfg.opts.org_agenda_span
  local orig_start = cfg.opts.org_agenda_start_day
  cfg.opts.org_agenda_span = 'day'
  cfg.opts.org_agenda_start_day = nil -- Will set via from parameter if needed

  -- Open agenda view
  local org = require('orgmode')
  org.action('agenda.agenda')

  -- Capture buffer content after render (use vim.defer_fn for async)
  vim.defer_fn(function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    -- Add org metadata header
    local output = {
      '#+title: Daily agenda',
      '#+date: ' .. date,
      '',
    }
    vim.list_extend(output, lines)

    -- Write to file
    vim.fn.mkdir(vim.fn.fnamemodify(output_path, ':h'), 'p')
    vim.fn.writefile(output, output_path)
    print('Wrote agenda to ' .. output_path)

    -- Restore original settings
    cfg.opts.org_agenda_span = orig_span
    cfg.opts.org_agenda_start_day = orig_start
  end, 100)
end

function M.setup()
  vim.api.nvim_create_user_command('DailyAgenda', function(args)
    M.export({ date = args.args ~= '' and args.args or nil })
  end, { nargs = '?' })
end

return M
