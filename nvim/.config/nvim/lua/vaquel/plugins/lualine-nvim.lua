return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'echasnovski/mini.icons' },
  config = function()
    local lualine = require 'lualine'
    local lazy_status = require 'lazy.status' -- to configure lazy pending updates count

    local function show_macro_recording()
      local recording_register = vim.fn.reg_recording()
      if recording_register == '' then
        return ''
      else
        return 'Recording @' .. recording_register
      end
    end

    lualine.setup {
      options = {
        theme = 'catppuccin-nvim',
      },
      extensions = { 'nvim-tree' },
      sections = {
        lualine_b = {
          {
            'filename',
            path = 1,
            fmt = function(name)
              return name:gsub('^packages/runtimes/', ''):gsub('^packages/libraries/[^/]+/', '')
            end,
          },
        },
        lualine_c = {
          {
            'macro-recording',
            fmt = show_macro_recording,
            color = { fg = '#ff9e64', gui = 'bold' },
          },
        },
        lualine_z = {
          {
            'lsp_status',
            icon = '', -- f013
            symbols = {
              -- Standard unicode symbols to cycle through for LSP progress:
              spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
              -- Standard unicode symbol for when LSP is done:
              done = '✓',
              -- Delimiter inserted between LSP names:
              separator = ' ',
            },
            -- List of LSP names to ignore (e.g., `null-ls`):
            ignore_lsp = { 'biome', 'tailwindcss', 'node', 'GitHub Copilot' },
          },
        },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = '#ff9e64' },
          },
          {
            'diff',
            'diagnostics',
            sources = { 'nvim_lsp', 'nvim_diagnostic' },
            sections = { 'error', 'warn', 'info', 'hint' },
          },
          { 'encoding' },
          { 'fileformat' },
          { 'filetype' },
        },
      },
    }

    -- Refresh the statusline immediately when macro recording starts/stops
    vim.api.nvim_create_autocmd('RecordingEnter', {
      callback = function()
        lualine.refresh { place = { 'statusline' } }
      end,
    })

    vim.api.nvim_create_autocmd('RecordingLeave', {
      callback = function()
        -- reg_recording() is still set during RecordingLeave, so defer the refresh
        local timer = vim.uv.new_timer()
        timer:start(
          50,
          0,
          vim.schedule_wrap(function()
            lualine.refresh { place = { 'statusline' } }
          end)
        )
      end,
    })
  end,
}
