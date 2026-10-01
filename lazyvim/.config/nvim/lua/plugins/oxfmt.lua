return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters.oxfmt = vim.tbl_deep_extend("force", opts.formatters.oxfmt or {}, {
        -- Only run in projects that configure oxfmt, so biome projects stay untouched
        require_cwd = true,
        -- Repos like attio keep an editor-only config that adds import sorting
        prepend_args = function(_, ctx)
          local root = vim.fs.root(ctx.dirname, "oxfmt.editor.config.ts")
          if root then
            return { "--config", root .. "/oxfmt.editor.config.ts" }
          end
          return {}
        end,
      })

      -- oxfmt wins over biome when a project configures both
      for _, formatters in pairs(opts.formatters_by_ft or {}) do
        if
          type(formatters) == "table"
          and vim.list_contains(formatters, "oxfmt")
          and vim.list_contains(formatters, "biome-check")
        then
          -- Reorder only the list part so option keys like lsp_format stay options
          for i, name in ipairs(formatters) do
            if name == "oxfmt" then
              table.remove(formatters, i)
              break
            end
          end
          table.insert(formatters, 1, "oxfmt")
          formatters.stop_after_first = true
        end
      end
    end,
  },
}
