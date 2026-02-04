return {
  'nvim-orgmode/orgmode',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-orgmode/telescope-orgmode.nvim',
    'nvim-orgmode/org-bullets.nvim',
    'Saghen/blink.cmp',
  },
  event = 'VeryLazy',
  config = function()
    require('orgmode').setup {
      org_agenda_files = {
        '~/orgfiles/*.org',
        '~/orgfiles/prj/*',
        '~/orgfiles/notes/*',
      },
      org_default_notes_file = '~/orgfiles/refile.org',
      org_refile_targets = {
        { filename = '~/orgfiles/cf.org', maxlevel = 1 },
        { path = '~/orgfiles/prj',        maxlevel = 1, type = 'directory' },
      },
      org_startup_folded = 'inherit',
      org_todo_keywords = { 'TODO(t)', 'NEXT(n)', 'INPROGRESS(i)', 'WAITING(w)', 'BLOCKED(b)', '|', 'DONE(d)', 'CANCELED(c)' },
      org_cycle_separator_lines = 1,
      org_capture_templates = {
        t = {
          description = 'Task',
          template = '* TODO %?\n  %u',
          target = '~/orgfiles/refile.org',
        },
        p = {
          description = 'New Project Idea',
          target = '~/orgfiles/projects.org',
          headline = 'Projects',
          template = '** %^{Project Title} :%^{Size|small|small,medium,large}:%^{Type|startup|startup,side-project,open-source-contribution}:\n%u\n%?',
        },
      },
      win_split_mode = 'vertical',
      mappings = {
        global = {
          org_refile = false,
        },
      },
    }
    require('org-bullets').setup()
    require('blink.cmp').setup {
      sources = {
        per_filetype = {
          org = { 'orgmode' },
        },
        providers = {
          orgmode = {
            name = 'Orgmode',
            module = 'orgmode.org.autocompletion.blink',
            fallbacks = { 'buffer' },
          },
        },
      },
    }

    require('telescope').setup({
      extensions = {
        orgmode = {
          max_depth = 3
        }
      }
    })
    require('telescope').load_extension 'orgmode'
    vim.keymap.set('n', '<leader>r', require('telescope').extensions.orgmode.refile_heading)
    vim.keymap.set('n', '<leader>oh', require('telescope').extensions.orgmode.search_headings)
    vim.keymap.set('n', '<leader>li', require('telescope').extensions.orgmode.insert_link)

    require('custom.daily_agenda').setup()
  end,
}
