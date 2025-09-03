local print_var_javascript = {
  'console.debug("%s ", %s)',
}

local print_javascript = {
  'console.debug("%s")',
}

return {
  'ThePrimeagen/refactoring.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter', 'folke/which-key.nvim' },
  event = 'BufEnter',
  keys = {
    { '<leader>re', ':Refactor extract ', mode = { 'v' }, desc = 'Extract' },
    { '<leader>rf', ':Refactor extract_to_file ', mode = { 'v' }, desc = 'Extract to a file' },
    { '<leader>rv', ':Refactor extract_var ', mode = { 'v' }, desc = 'Extract var' },
    { '<leader>ri', ':Refactor inline_var', mode = { 'n', 'v' }, desc = 'Inline var' },
    { '<leader>rI', ':Refactor inline_func', mode = { 'n' }, desc = 'inline func' },
    { '<leader>rb', ':Refactor extract_block_to_file', mode = { 'n' }, desc = 'Extract block to a file' },
    -- stylua: ignore
    { '<leader>rlm', function() require('refactoring').debug.printf { below = true } end, mode = {'n', 'v'}, desc = '[L]og [m]essage' },
    {
      '<leader>rlp',
      function()
        require('refactoring').debug.printf { below = true }
      end,
      mode = { 'n', 'v' },
      desc = '[L]og [m]essage',
    },
    -- stylua: ignore
    { '<leader>rlv', function() require('refactoring').debug.print_var({ below = true}) end, mode = { 'n'},  desc = '[L]og var below' },
    {
      '<leader>rlV',
      function()
        require('refactoring').debug.print_var { below = false }
      end,
      mode = { 'n' },
      desc = '[L]og var above',
    },
    -- stylua: ignore
    { '<leader>rc', function() require('refactoring').debug.cleanup({}) end, mode = { 'n'},  desc = 'Clean debug print & logs' },
  },
  opts = {
    print_var_statements = {
      typescript = print_var_javascript,
      typescriptreact = print_var_javascript,
      javascript = print_var_javascript,
      javascriptreact = print_var_javascript,
      lua = { "vim.notify('%s ' .. vim.inspect(%s))" },
    },
    printf_statements = {
      typescript = print_javascript,
      typescriptreact = print_javascript,
      javascript = print_javascript,
      javascriptreact = print_javascript,
    },
  },
  config = function(_, opts)
    require('which-key').add {
      { '<leader>r', group = '[R]efector' },
    }

    require('refactoring').setup(opts)
  end,
}
