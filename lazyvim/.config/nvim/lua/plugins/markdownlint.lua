return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          -- Drop MD013/line-length everywhere; filtering keeps project configs in effect
          parser = function(output, bufnr, cwd)
            local parse = require("lint.linters.markdownlint-cli2").parser
            return vim.tbl_filter(function(diagnostic)
              return not diagnostic.message:find("MD013/", 1, true)
            end, parse(output, bufnr, cwd))
          end,
        },
      },
    },
  },
}
