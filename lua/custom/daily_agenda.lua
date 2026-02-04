local M = {}

local LAST_RUN_FILE = vim.fn.expand('~/orgfiles/agenda/.last_run')

function M._get_last_run_date()
  if vim.fn.filereadable(LAST_RUN_FILE) == 1 then
    local lines = vim.fn.readfile(LAST_RUN_FILE)
    if #lines > 0 and lines[1]:match('%d%d%d%d%-%d%d%-%d%d') then
      return lines[1]
    end
  end
  -- Default to yesterday if no last run
  return os.date('%Y-%m-%d', os.time() - 86400)
end

function M._save_last_run_date(date)
  vim.fn.mkdir(vim.fn.fnamemodify(LAST_RUN_FILE, ':h'), 'p')
  vim.fn.writefile({ date }, LAST_RUN_FILE)
end

function M._days_between(date1, date2)
  local y1, m1, d1 = date1:match('(%d+)-(%d+)-(%d+)')
  local y2, m2, d2 = date2:match('(%d+)-(%d+)-(%d+)')
  local t1 = os.time({ year = tonumber(y1), month = tonumber(m1), day = tonumber(d1) })
  local t2 = os.time({ year = tonumber(y2), month = tonumber(m2), day = tonumber(d2) })
  return math.floor((t2 - t1) / 86400)
end

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

function M._capture_agenda_async(start_day, span, filter_fn, callback)
  local cfg = require('orgmode.config')
  local org = require('orgmode')

  -- Save and set config
  local orig_span = cfg.opts.org_agenda_span
  local orig_start = cfg.opts.org_agenda_start_day
  cfg.opts.org_agenda_span = span or 'day'
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

  -- Get last run date and calculate span for completed section
  local last_run = M._get_last_run_date()
  local days_back = M._days_between(last_run, date)
  -- Ensure at least 1 day, cap at 14 to avoid huge spans
  days_back = math.max(1, math.min(days_back, 14))

  -- Build headline index for hierarchy lookup
  local index = M._build_headline_index()

  -- Chain: get completed since last run, then today's agenda, then write
  local start_offset = string.format('-%dd', days_back)
  M._capture_agenda_async(start_offset, days_back, function(line)
    return line:match('%sDONE%s')
  end, function(completed)
    M._capture_agenda_async(nil, 'day', nil, function(today_lines)
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
      local completed_label = days_back == 1
        and string.format('Completed (%s):', last_run)
        or string.format('Completed (since %s):', last_run)
      table.insert(output, completed_label)
      if #completed == 0 then
        table.insert(output, '  No tasks were completed.')
      else
        vim.list_extend(output, completed)
      end

      -- Write to file
      vim.fn.mkdir(vim.fn.fnamemodify(output_path, ':h'), 'p')
      vim.fn.writefile(output, output_path)

      -- Save this run date
      M._save_last_run_date(date)

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
