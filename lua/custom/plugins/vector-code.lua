return {
  'Davidyz/VectorCode',
  dependencies = { 'nvim-lua/plenary.nvim' },
  build = 'pipx upgrade vectorcode', -- optional but recommended. This keeps your CLI up-to-date.
  cmd = 'VectorCode', -- if you're lazy-loading VectorCode
}

-- TODO: configure git hooks to run VectorCode on commit.
-- Have vectorcode automatically init and vectorize on new projects.
-- run standalone chromadb server?
