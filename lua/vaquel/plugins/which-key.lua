return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  lazy = false,
  config = function() -- This is the function that runs, AFTER loading
    require('which-key').setup()

    -- document existing key chains
    require('which-key').add {
      { '<leader>c', group = '[C]ode' },
      { '<leader>m', group = 'Docu[m]ent' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>f', group = '[F]ind files' },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>g', group = '[G]it', mode = { 'n' } },
      { '<leader>e', group = 'File [e]xplorer', mode = { 'n' } },
      { '<leader>h', group = '[H]arpoon' },
      { '<leader>s', group = '[S]earch with Flash' },
      { '<leader>t', group = '[t]rouble' },
      { '<leader>T', group = '[T]ests' },
    }
  end,
}
