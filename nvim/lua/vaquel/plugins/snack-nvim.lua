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
    scratch = {
      enabled = true,
    },
    terminal = {
      enabled = true,
      bo = {
        filetype = 'snacks_terminal',
      },
      wo = {},
      keys = {
        q = 'hide',
        gf = function(self)
          local f = vim.fn.findfile(vim.fn.expand '<cfile>', '**')
          if f == '' then
            Snacks.notify.warn 'No file under cursor'
          else
            self:hide()
            vim.schedule(function()
              vim.cmd('e ' .. f)
            end)
          end
        end,
        term_normal = {
          '<esc>',
          function(self)
            self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
            if self.esc_timer:is_active() then
              self.esc_timer:stop()
              vim.cmd 'stopinsert'
            else
              self.esc_timer:start(200, 0, function() end)
              return '<esc>'
            end
          end,
          mode = 't',
          expr = true,
          desc = 'Double escape to normal mode',
        },
      },
    },
    words = { enabled = true },
    picker = {
      enabled = true,
      matcher = {
        frecency = true,
        smartcase = true,
        ignorecase = true,
        filename_bonus = true,
      },
      formatters = {
        file = {
          filename_first = true,
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
      jump = {
        jumplist = true,
        reuse_win = true,
      },
    },
  },
  keys = {
    -- stylua: ignore start
    -- Picker keymaps
    { '<leader>fF', function() Snacks.picker.git_files({untracked = true}) end, desc = '[F]ind [F]iles' },
    { '<leader>ff', function() Snacks.picker.files() end, desc = '[F]ind Git [f]iles' },
    { '<leader>fg', function() Snacks.picker.grep()  end, desc = '[F]ind [G]rep' },
    { '<leader>fs', function() Snacks.picker.lsp_workspace_symbols() end, desc = '[F]ind Type definitions' },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent"},
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "[F]ind [K]eymaps"},
    { "<leader>fh", function() Snacks.picker.help() end, desc = "[F]ind [H]elp"},
    { "<leader>ft", function() Snacks.picker.todo_comments({keywords = {'TODO', 'TODO_ADAM'}}) end, desc = "[F]ind [T]odos"},
    { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "[F]ind Visual selection or [w]ord", mode = { "n", "x" } },
    { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "[F]ind workspace [d]iagnostics" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "[F]ind open [b]uffers" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    -- Git keymaps
    { '<leader>gt', function() Snacks.lazygit.open()end, desc = 'Open Lazy[G]it [t]ree' },
    {'<leader>go', function() Snacks.gitbrowse.open() end, desc = "Open file in Git repo web browser"},
    -- Notifier keymaps
    -- Scratch keymaps
    { '<leader>nq', function() Snacks.notifier.hide() end, desc = '[N]otifier [Q]uit' },
    { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    -- stylua: ignore end
  },
  dependencies = {
    'folke/todo-comments.nvim',
  },
}
