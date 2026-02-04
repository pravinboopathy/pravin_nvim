local M = {}

function M._capture_agenda_async(start_day, filter_fn, callback)
  local cfg = require('orgmode.config')
  local org = require('orgmode')

  -- Save and set config
  local orig_span = cfg.opts.org_agenda_span
  local orig_start = cfg.opts.org_agenda_start_day
  cfg.opts.org_agenda_span = 'day'
  cfg.opts.org_agenda_start_day = start_day

  -- Open agenda
  org.action('agenda.agenda')

  -- Wait for render then capture
  vim.defer_fn(function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    -- Close agenda buffer
    vim.cmd('bdelete')

    -- Restore config
    cfg.opts.org_agenda_span = orig_span
    cfg.opts.org_agenda_start_day = orig_start

    -- Apply filter if provided
    if filter_fn then
      local filtered = {}
      for _, line in ipairs(lines) do
        if filter_fn(line) then
          table.insert(filtered, line)
        end
      end
      callback(filtered)
    else
      callback(lines)
    end
  end, 100)
end

function M.export(opts)
  opts = opts or {}
  local date = opts.date or os.date('%Y-%m-%d')
  local output_path = opts.output or ('agenda/' .. date .. '.org')

  -- Calculate yesterday's date for display
  local year, month, day = date:match('(%d+)-(%d+)-(%d+)')
  local timestamp = os.time({ year = tonumber(year), month = tonumber(month), day = tonumber(day) })
  local yesterday = os.date('%Y-%m-%d', timestamp - 86400)

  -- Chain: get yesterday's completed, then today's agenda, then write
  M._capture_agenda_async('-1d', function(line)
    return line:match('%sDONE%s')
  end, function(completed)
    M._capture_agenda_async(nil, nil, function(today_lines)
      -- Build output
      local output = {
        '#+title: Daily agenda',
        '#+date: ' .. date,
        '',
      }
      vim.list_extend(output, today_lines)

      -- Add completed section
      table.insert(output, '')
      table.insert(output, 'Completed (' .. yesterday .. '):')
      if #completed == 0 then
        table.insert(output, '  No tasks were completed.')
      else
        vim.list_extend(output, completed)
      end

      -- Write to file
      vim.fn.mkdir(vim.fn.fnamemodify(output_path, ':h'), 'p')
      vim.fn.writefile(output, output_path)
      print('Wrote agenda to ' .. output_path)
    end)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command('DailyAgenda', function(args)
    M.export({ date = args.args ~= '' and args.args or nil })
  end, { nargs = '?' })
end

return M
