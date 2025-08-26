return {
  'stevearc/oil.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/snacks.nvim' },
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
      show_hidden = true,
      natural_order = true,
      is_always_hidden = function(name)
        return name == '.git' or name == '.DS_Store'
      end,
    },
    lsp_file_methods = {
      enabled = false,
      -- Set to true to autosave buffers that are updated with LSP willRenameFiles
      -- Set to "unmodified" to only save unmodified buffers
      autosave_changes = true,
      timeout_ms = 60 * 1000,
    },
    watch_for_changes = true,
    win_options = {
      wrap = true,
    },
    keymaps = {
      ['<C-q>'] = 'actions.send_to_qflist',
      ['g?'] = 'actions.show_help',
      ['<CR>'] = 'actions.select',
      ['<C-v>'] = { 'actions.select', opts = { vertical = true }, desc = 'Open the entry in a vertical split' },
      ['<C-s>'] = { 'actions.select', opts = { horizontal = true }, desc = 'Open the entry in a horizontal split' },
      ['<C-p>'] = 'actions.preview',
      ['<C-c>'] = 'actions.close',
      ['<C-r>'] = 'actions.refresh',
      ['-'] = 'actions.parent',
      ['_'] = 'actions.open_cwd',
      ['`'] = 'actions.cd',
      ['gy'] = {
        callback = function()
          local oil = require 'oil'
          local path = oil.get_current_dir()
          vim.fn.setreg('+', path)
          vim.notify('Copied to clipboard: ' .. path)
        end,
        desc = 'Copy directory path to clipboard',
      },
      ['gs'] = 'actions.change_sort',
      ['gx'] = 'actions.open_external',
      ['g.'] = 'actions.toggle_hidden',
      ['g\\'] = 'actions.toggle_trash',
    },
    use_default_keymaps = false,
  },
  config = function(_, opts)
    require('oil').setup(opts)
    vim.keymap.set('n', '-', '<cmd>Oil<CR>', { noremap = true })

    local augroup = vim.api.nvim_create_augroup('oil-actions-post', { clear = true })
    vim.api.nvim_create_autocmd('User', {
      pattern = 'OilActionsPost',
      group = augroup,
      callback = function(e)
        if e.data.actions == nil then
          return
        end
        for _, action in ipairs(e.data.actions) do
          if action.entry_type == 'file' and action.type == 'delete' then
            local file = action.url:sub(7)
            local bufnr = vim.fn.bufnr(file)

            if bufnr >= 0 then
              vim.api.nvim_buf_delete(bufnr, { force = true })
            end
          end
        end
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'OilActionsPost',
      group = augroup,
      callback = function(event)
        if event.data.actions.type == 'move' then
          Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
        end
      end,
    })
  end,
}
