return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  -- `main` is the maintained branch (Neovim 0.11+). `master` is frozen and no longer
  -- provides `nvim-treesitter.configs`, which is what the old module-based setup used.
  branch = 'main',
  lazy = false, -- the `main` branch does not support lazy-loading
  build = ':TSUpdate',
  opts = {
    ensure_installed = {
      'ruby',
      'bash',
      'c',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'vim',
      'vimdoc',
      'typescript',
      'tsx',
      'json',
      'gitignore',
      'css',
      'styled',
      'objc',
    },
    -- Autoinstall languages that are not installed
    auto_install = true,
    -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
    --  If you are experiencing weird indenting issues, add the language to
    --  the list of additional_vim_regex_highlighting and disabled languages for indent.
    additional_vim_regex_highlighting = { 'ruby' },
    indent = { disable = { 'ruby' } },
    incremental_selection = {
      keymaps = {
        init_selection = '<C-s>',
        node_incremental = '<C-s>',
        node_decremental = '<BS>',
      },
    },
  },
  config = function(_, opts)
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    --
    -- On `main` the plugin only installs parsers and queries. Highlighting and indentation
    -- come from Neovim itself and are enabled per buffer below.
    local ts = require 'nvim-treesitter'

    -- Install missing parsers from `ensure_installed` in the background (installed ones are skipped).
    ts.install(opts.ensure_installed)

    ---@param lang string
    ---@return boolean
    local function has_parser(lang)
      local ok, loaded = pcall(vim.treesitter.language.add, lang)
      return ok and loaded ~= nil and loaded ~= false
    end

    ---@param buf integer
    ---@param lang string
    local function enable(buf, lang)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      vim.treesitter.start(buf, lang)
      if vim.list_contains(opts.additional_vim_regex_highlighting, lang) then
        vim.bo[buf].syntax = 'ON'
      end
      if not vim.list_contains(opts.indent.disable, lang) then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      -- Incremental selection: see `lua/vaquel/shared/incremental-selection.lua` for why this is
      -- not Neovim 0.12's builtin `an`/`in`.
      local select = require 'vaquel.shared.incremental-selection'
      local keys = opts.incremental_selection.keymaps
      vim.keymap.set('n', keys.init_selection, select.init_selection, { buffer = buf, desc = 'Select treesitter node' })
      vim.keymap.set('x', keys.node_incremental, select.node_incremental, { buffer = buf, desc = 'Expand selection to parent node' })
      vim.keymap.set('x', keys.node_decremental, select.node_decremental, { buffer = buf, desc = 'Shrink selection to previous node' })
    end

    local install_attempted = {} ---@type table<string, boolean>

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('vaquel_treesitter', { clear = true }),
      desc = 'Enable treesitter highlighting and indentation',
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if not lang then
          return
        end

        if has_parser(lang) then
          enable(ev.buf, lang)
        elseif opts.auto_install and not install_attempted[lang] and require('nvim-treesitter.parsers')[lang] then
          install_attempted[lang] = true
          ts.install({ lang }):await(function(err, ok)
            if not err and ok then
              vim.schedule(function()
                enable(ev.buf, lang)
              end)
            end
          end)
        end
      end,
    })

    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  end,
}
