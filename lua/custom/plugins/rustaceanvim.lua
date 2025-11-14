-- Rust development plugin with enhanced rust-analyzer integration
return {
  'mrcjkb/rustaceanvim',
  version = '^5', -- Recommended to use the latest stable version
  lazy = false, -- This plugin is already lazy-loaded on Rust files
  ft = { 'rust' },
  opts = {
    server = {
      on_attach = function(client, bufnr)
        -- Custom keymaps for Rust-specific features
        -- NOTE: These are IN ADDITION to the standard LSP keymaps from lspconfig.lua
        -- Standard LSP commands like gd, <leader>gr, <leader>gn, etc. still work!
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'Rust: ' .. desc })
        end

        -- Rust-specific commands provided by rust-analyzer

        -- Run Runnables: Shows fuzzy menu of tests, binaries, examples to run
        -- Example: Run a single test instead of entire test suite
        map('<leader>rr', '<cmd>RustLsp runnables<cr>', '[R]un [R]unnables')

        -- Run Debuggables: Same as runnables but with debugger attached (requires codelldb)
        -- Example: Set breakpoints and step through test execution
        map('<leader>rd', '<cmd>RustLsp debuggables<cr>', '[R]un [D]ebuggables')

        -- Expand Macro: Shows what a macro expands to
        -- Example: See what println! or #[derive(Debug)] actually generates
        map('<leader>re', '<cmd>RustLsp expandMacro<cr>', '[R]ust [E]xpand Macro')

        -- Open Cargo.toml: Jump to nearest Cargo.toml in workspace
        -- Example: Quickly add dependencies or check features
        map('<leader>rc', '<cmd>RustLsp openCargo<cr>', '[R]ust Open [C]argo.toml')

        -- Parent Module: Navigate up the module hierarchy
        -- Example: From src/commands/clone.rs → src/commands/mod.rs
        map('<leader>rp', '<cmd>RustLsp parentModule<cr>', '[R]ust [P]arent Module')

        -- Rebuild Proc Macros: Force rust-analyzer to rebuild macro cache
        -- Example: Fix stale errors after adding derive macros like serde or clap
        map('<leader>rm', '<cmd>RustLsp rebuildProcMacros<cr>', '[R]ust Rebuild Proc [M]acros')
      end,
      default_settings = {
        ['rust-analyzer'] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
            buildScripts = {
              enable = true,
            },
          },
          -- Check on save with clippy for better lints
          checkOnSave = {
            command = 'clippy',
          },
          -- Enable procedural macro support
          procMacro = {
            enable = true,
          },
          -- Inlay hints configuration
          inlayHints = {
            bindingModeHints = {
              enable = false,
            },
            chainingHints = {
              enable = true,
            },
            closingBraceHints = {
              minLines = 25,
            },
            closureReturnTypeHints = {
              enable = 'never',
            },
            lifetimeElisionHints = {
              enable = 'never',
              useParameterNames = false,
            },
            maxLength = 25,
            parameterHints = {
              enable = true,
            },
            reborrowHints = {
              enable = 'never',
            },
            renderColons = true,
            typeHints = {
              enable = true,
              hideClosureInitialization = false,
              hideNamedConstructor = false,
            },
          },
        },
      },
    },
  },
  config = function(_, opts)
    vim.g.rustaceanvim = vim.tbl_deep_extend('keep', vim.g.rustaceanvim or {}, opts or {})
  end,
}
-- vim: ts=2 sts=2 sw=2 et
