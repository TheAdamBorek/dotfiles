local M = {}

local function setupBiomeFixAll()
  local conform = require 'conform'
  vim.keymap.set('n', '<leader>cl', function()
    conform.format {
      async = false,
      formatters = { 'biome-check' },
    }
  end, { desc = 'Fix all [l]int problems with Biome' })
end

local function setup_biome_organize_imports_on_save()
  vim.api.nvim_create_autocmd('BufWritePre', {
    desc = 'Organize imports with Biome on save',
    pattern = { '*.js', '*.jsx', '*.ts', '*.tsx' },
    group = vim.api.nvim_create_augroup('biome-organize-imports-on-save', { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local biome_lsp_client = vim.lsp.get_clients({ bufnr = bufnr, name = 'biome' })[1]
      local start_pos = { line = 0, character = 0 }
      local end_pos = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local end_line = #end_pos

      local range = {
        start = start_pos,
        ['end'] = { line = end_line - 1, character = #end_pos[end_line] },
      }

      local params = {
        textDocument = {
          uri = vim.uri_from_bufnr(bufnr),
        },
        context = {
          diagnostics = {},
          only = { 'source.organizeImports.biome' },
        },
        range = range,
      }

      local response = biome_lsp_client.request_sync('textDocument/codeAction', params, 5000, bufnr)
      local result, error = response.result, response.error
      if result ~= nil then
        for _, action in ipairs(result) do
          if action.kind == 'source.organizeImports.biome' and action.edit ~= nil then
            vim.lsp.util.apply_workspace_edit(action.edit, 'utf-8')
          end
        end
      else
        vim.notify('Failed to organize imports with Biome:\n\n' .. vim.inspect(error), vim.log.levels.WARN)
      end
    end,
  })
end

local function setup_mini_ai_text_objects()
  local mini_ai = require 'mini.ai'
  local spec_treesitter = mini_ai.gen_spec.treesitter

  mini_ai.setup {
    custom_textobjects = {
      f = spec_treesitter { a = { '@function.outer' }, i = '@function.inner' },
      a = spec_treesitter {
        -- Around: Full selection (e.g., entire prop/arg/property including comma)
        a = {
          '@prop.outer', -- JSX props
          '@parameter.outer', -- Function call args + definition params (built-in)
          '@property.outer', -- Object properties
          '@element.outer', -- Array's element
        },
        -- Inner: Core content (e.g., excluding commas/type annotations)
        i = {
          '@prop.inner',
          '@parameter.inner',
          '@property.inner',
          '@element.inner', -- Array's element
        },
      },
      n_lines = 2,
    },
  }
end

M.apply = function()
  setupBiomeFixAll()
  setup_biome_organize_imports_on_save()
  setup_mini_ai_text_objects()
end

return M
