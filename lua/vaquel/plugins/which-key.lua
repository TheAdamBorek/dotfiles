-- For example, in the following configuration, we use:
--  event = 'vimenter'
--
-- which loads which-key before all the UI elements are loaded. Events can be
-- normal autocommands events (`:help autocmd-events`).
--
-- Then, because we use the `config` key, the configuration only runs
-- after the plugin has been loaded:
--  config = function() ... end

return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'vimenter', -- Sets the loading event to 'VimEnter'
  config = function() -- This is the function that runs, AFTER loading
    require('which-key').setup()

    -- document existing key chains
    require('which-key').add {
      { '<leader>c', group = '[C]ode' },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>g', group = '[G]it', mode = { 'n' } },
      { '<leader>e', group = 'File [e]xplorer', mode = { 'n' } },
      { '<leader>h', group = '[H]arpoon' },
      { '<leader>t', group = '[t]ests' },
      { '<leader>T', group = '[T]rouble' },
    }
  end,
}
