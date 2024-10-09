return { -- Fuzzy finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'vimenter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- if encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- this is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    -- useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons' },
    'nvim-telescope/telescope-live-grep-args.nvim',
    'nvim-telescope/telescope-smart-history.nvim',
    'kkharji/sqlite.lua',
  },
  config = function()
    -- telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- the easiest way to use Telescope, is to start by doing something like:
    --  :telescope help_tags
    --
    -- after running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- two important keymaps to use while in Telescope are:
    --  - insert mode: <c-/>
    --  - normal mode: ?
    --
    -- this opens a window that shows you all of the keymaps for the current
    -- telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ configure telescope ]]
    -- see `:help telescope` and `:help telescope.setup()`
    local actions = require 'telescope.actions'
    local liveGrepArgsActions = require 'telescope-live-grep-args.actions'

    --- Quote the prompt and append a postfix to the prompt
    --- @param filetypes string[] : the filetype
    local function quote_prompt_with_file_type(filetypes)
      return function(prompt_bufnr)
        local globPattern = '**/*X*/**'
        if #filetypes > 0 then
          globPattern = globPattern .. string.format('/*.{%s}', table.concat(filetypes, ','))
        end
        local postfix = string.format(' --iglob "%s"', globPattern)

        local action = liveGrepArgsActions.quote_prompt { postfix = postfix }
        action(prompt_bufnr)
        -- Go to the middle of --iglob where the X is
        vim.cmd 'norm! FXx'
      end
    end

    require('telescope').setup {
      -- you can put your default mappings / updates / etc. in here
      --  all the info you're looking for is in `:help telescope.setup()`
      --
      defaults = {
        path_display = { 'truncate' },
        mappings = {
          i = {
            ['<C-k>'] = actions.move_selection_previous,
            ['<C-j>'] = actions.move_selection_next,
            ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
        history = {
          path = '~/.local/share/nvim/telescope_history.sqlite3',
          limit = 100,
        },
      },
      -- pickers = {}
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
        live_grep_args = {
          auto_quoting = true,
          mappings = {
            i = {
              ['<C-t>'] = quote_prompt_with_file_type { 'ts', 'tsx' },
              ['<C-p>'] = liveGrepArgsActions.quote_prompt(),
            },
          },
        },
      },
    }

    -- enable telescope extensions if they are installed
    local telescope = require 'telescope'
    pcall(telescope.load_extension, 'fzf')
    pcall(telescope.load_extension, 'ui-select')
    pcall(telescope.load_extension, 'live_grep_args')
    pcall(telescope.load_extension, 'smart_history')

    -- see `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>ff', function()
      builtin.git_files { show_untracked = true }
    end, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>gc', function()
      builtin.git_files {
        show_untracked = false,
        recurse_submodules = false,
        git_command = { 'git', 'diff', '--name-only' },
      }
    end, { desc = 'List git [c]hanged files' })
    vim.keymap.set('n', '<leader>fF', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>fs', builtin.lsp_dynamic_workspace_symbols, { desc = '[S]earch [S]ymbols' })
    vim.keymap.set({ 'n', 'v' }, '<leader>fw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>fg', require('telescope').extensions.live_grep_args.live_grep_args, { desc = '[S]earch by [G]rep with [b]lob' })
    vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

    -- slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- you can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- it's also possible to pass additional configuration options.
    --  see `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>f/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>fn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
