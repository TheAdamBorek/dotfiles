-- oil.nvim: edit the filesystem like a normal buffer
return {
  {
    "stevearc/oil.nvim",
    lazy = false, -- required so oil can take over netrw / `nvim <dir>`
    dependencies = { "nvim-mini/mini.icons" },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      watch_for_changes = true,
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        -- keep LazyVim's window navigation on <C-h>/<C-l>
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-r>"] = "actions.refresh",
        ["q"] = "actions.close",
      },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Oil (parent dir)" },
      {
        "_",
        function()
          require("oil").open(vim.uv.cwd())
        end,
        desc = "Oil (cwd)",
      },
    },
  },
}
