return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  build = 'cd app && yarn install',
  config = function()
    -- Set to 1 to auto-start the preview when entering a Markdown buffer
    vim.g.mkdp_auto_start = 0

    -- Set to 1 to auto-close the preview when leaving the Markdown buffer
    vim.g.mkdp_auto_close = 1

    -- Refresh Markdown preview only on save or leaving insert mode
    vim.g.mkdp_refresh_slow = 0

    -- Allow the MarkdownPreview command for all file types (not just Markdown)
    vim.g.mkdp_command_for_global = 0

    -- Set to 1 to allow preview server access to other devices in the network
    vim.g.mkdp_open_to_the_world = 0

    -- Custom IP address to open the preview page
    vim.g.mkdp_open_ip = ''

    -- Specify the browser to open the preview page
    vim.g.mkdp_browser = ''

    -- Echo the preview page URL in the command line when opened
    vim.g.mkdp_echo_preview_url = 0

    -- Custom Vim function to open the preview page with URL as a parameter
    vim.g.mkdp_browserfunc = ''

    -- Markdown rendering options
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = {},
      disable_sync_scroll = 0,
      sync_scroll_type = 'middle',
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
      disable_filename = 0,
      toc = {},
    }

    -- Custom Markdown CSS
    vim.g.mkdp_markdown_css = ''

    -- Custom highlight CSS
    vim.g.mkdp_highlight_css = ''

    -- Custom port for the server
    vim.g.mkdp_port = ''

    -- Preview page title format
    vim.g.mkdp_page_title = '「${name}」'

    -- Custom location for images
    vim.g.mkdp_images_path = '/home/user/.markdown_images'

    -- Recognized filetypes
    vim.g.mkdp_filetypes = { 'markdown' }

    -- Default theme for the preview (dark or light)
    vim.g.mkdp_theme = 'dark'

    -- Combine preview window
    vim.g.mkdp_combine_preview = 0

    -- Auto-refresh combined preview contents when changing the Markdown buffer
    vim.g.mkdp_combine_preview_auto_refresh = 1
  end,
  init = function()
    -- Initialize filetypes for MarkdownPreview commands
    vim.g.mkdp_filetypes = { 'markdown' }
  end,
  ft = { 'markdown' },
}
