local truncate_width = vim.api.nvim_win_get_width(0) * 0.35
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true, what = 'file', branch = 'master' },
    gitbrowse = { enabled = true },
    -- explorer = { enabled = true },
    indent = { enabled = true, animate = {
      enabled = false,
    } },
    input = { enabled = true },
    notify = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    words = { enabled = true },
    picker = {
      enabled = true,
      matcher = {
        frecency = true,
      },
      formatters = {
        file = {
          truncate = truncate_width,
        },
      },
      debug = {
        scores = true,
      },
      layout = {
        preset = 'default',
      },
      win = {
        input = {
          keys = {
            ['<Down>'] = { 'history_forward', mode = { 'i', 'n' } },
            ['<Up>'] = { 'history_back', mode = { 'i', 'n' } },
            ['<C-d>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
            ['<C-u>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
          },
        },
      },
    },
  },
  keys = {
    -- stylua: ignore start
    -- Picker keymaps
    { '<leader>fF', function() Snacks.picker.files() end, desc = '[F]ind [F]iles' },
    { '<leader>ff', function() Snacks.picker.git_files { untracked = true } end, desc = '[F]ind Git [f]iles' },
    { '<leader>fg', function() Snacks.picker.git_grep({untracked = true})  end, desc = 'Grep in [g]it' },
    { '<leader>fs', function() Snacks.picker.lsp_workspace_symbols() end, desc = '[F]ind Type definitions' },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent"},
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "[F]ind [K]eymaps"},
    { "<leader>fh", function() Snacks.picker.help() end, desc = "[F]ind [H]elp"},
    { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "[F]ind Visual selection or [w]ord", mode = { "n", "x" } },
    { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "[F]ind workspace [d]iagnostics" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "[F]ind open [b]uffers" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    -- Git keymaps
    { '<leader>gt', function() Snacks.lazygit.open()end, desc = 'Open Lazy[G]it [t]ree' },
    {'<leader>go', function() Snacks.gitbrowse.open() end, desc = "Open file in Git repo web browser"},
    -- Notifier keymaps
    { '<leader>nq', function() Snacks.notifier.hide() end, desc = '[N]otifier [Q]uit' },
    -- stylua: ignore end
  },
}
