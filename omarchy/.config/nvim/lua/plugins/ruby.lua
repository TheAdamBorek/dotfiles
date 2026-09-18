local ruby_lsp_dir = vim.fn.stdpath("data") .. "/mason/packages/ruby-lsp"

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          -- Mason's generated executable has /usr/bin/ruby in its shebang.
          -- Run it explicitly with the Ruby selected by mise instead.
          cmd = function(dispatchers, config)
            return vim.lsp.rpc.start({
              "mise",
              "exec",
              "--",
              "ruby",
              ruby_lsp_dir .. "/bin/ruby-lsp",
              "--use-launcher",
              -- ruby-lsp-rails 0.5 fixes Rails 8.1 index metadata in model hovers.
              "--beta",
            }, dispatchers, {
              cwd = config.cmd_cwd or config.root_dir,
              env = vim.tbl_extend("force", config.cmd_env or {}, {
                GEM_PATH = ruby_lsp_dir .. ":" .. (vim.env.GEM_PATH or ""),
              }),
            })
          end,
        },
      },
    },
  },
}
