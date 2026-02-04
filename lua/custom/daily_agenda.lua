local M = {}

-- Build lookup table: { [category] = { [title] = { ancestors = {...} } } }
function M._build_headline_index()
  local Files = require('orgmode.files')
  local cfg = require('orgmode.config')

  local files = Files:new({ paths = cfg.opts.org_agenda_files })
  files:load_sync()

  local index = {}

  for _, orgfile in ipairs(files:all()) do
    if orgfile.filename:match('/agenda/') then
      goto continue
    end

    local category = vim.fn.fnamemodify(orgfile.filename, ':t:r')
    index[category] = index[category] or {}

    -- Track parent stack by level
    local parent_stack = {} -- parent_stack[level] = title at that level

    for _, headline in ipairs(orgfile:get_headlines()) do
      local level = headline:get_level()
      local title = headline:get_title()

      -- Update parent stack - clear anything at or below current level
      for l = level, 10 do
        parent_stack[l] = nil
      end

      -- Build ancestors from parent stack (levels 1 to level-1)
      local ancestors = {}
      for l = 1, level - 1 do
        if parent_stack[l] then
          table.insert(ancestors, parent_stack[l])
        end
      end

      -- Store this headline's title at its level for children
      parent_stack[level] = title

      index[category][title] = {
        ancestors = ancestors,
      }
    end

    ::continue::
  end

  return index
end

-- Add hierarchy prefix to agenda lines
function M._add_hierarchy(lines, index)
  local result = {}
  for _, line in ipairs(lines) do
    -- Parse agenda line: "  category:          Sched...: TODO title" or similar
    local category, rest = line:match('^%s+([%w%-_]+):%s+(.+)$')
    if category and rest and index[category] then
      -- Extract title (after TODO state or just the text)
      -- Format: "Scheduled: TODO title" or "Sched. 1x: WAITING title"
      local title = rest:match('[A-Z]+%s+(.+)$') or rest:match(':%s+(.+)$')
      if title then
        local entry = index[category][title]
        if entry and #entry.ancestors > 0 then
          -- Insert hierarchy before the title
          local hierarchy = table.concat(entry.ancestors, ' > ') .. ' > '
          -- Reconstruct line with hierarchy
          local prefix, todo_and_title = rest:match('^(.-%s)([A-Z]+%s+.+)$')
          if prefix and todo_and_title then
            local todo, orig_title = todo_and_title:match('^([A-Z]+)%s+(.+)$')
            if todo then
              line = string.format('  %-18s %s%s %s', category .. ':', prefix, todo, hierarchy .. orig_title)
            end
          end
        end
      end
    end
    table.insert(result, line)
  end
  return result
end

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

  -- Build headline index for hierarchy lookup
  local index = M._build_headline_index()

  -- Chain: get yesterday's completed, then today's agenda, then write
  M._capture_agenda_async('-1d', function(line)
    return line:match('%sDONE%s')
  end, function(completed)
    M._capture_agenda_async(nil, nil, function(today_lines)
      -- Add hierarchy to lines
      today_lines = M._add_hierarchy(today_lines, index)
      completed = M._add_hierarchy(completed, index)

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
