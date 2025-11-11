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
      org_agenda_files = '~/orgfiles/**/*',
      org_default_notes_file = '~/orgfiles/refile.org',
      org_startup_folded = 'inherit',
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
          template = '** %^{Project Title} :%^{Size|small|small,medium,large}:%^{Type|startup|satartup,side-project,open-source-contribution}:\n%u\n%?',
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

    require('telescope').setup()
    require('telescope').load_extension 'orgmode'
    vim.keymap.set('n', '<leader>r', require('telescope').extensions.orgmode.refile_heading)
    vim.keymap.set('n', '<leader>fh', require('telescope').extensions.orgmode.search_headings)
    vim.keymap.set('n', '<leader>li', require('telescope').extensions.orgmode.insert_link)
  end,
}
