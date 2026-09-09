-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape insert mode" })

vim.keymap.set("n", "<leader>md", "<cmd>delmarks A-Z<CR>", { desc = "Delete all global marks" })

vim.keymap.set({ "n", "x" }, "<leader>my", function()
  local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  local result = path
  local mode = vim.api.nvim_get_mode().mode

  if mode == "v" or mode == "V" or mode == "\22" then
    local first_line = vim.fn.line("v")
    local last_line = vim.fn.line(".")
    if first_line > last_line then
      first_line, last_line = last_line, first_line
    end
    result = ("%s:%d-%d"):format(path, first_line, last_line)
  end

  vim.fn.setreg("+", result)
  vim.notify(('Copied "%s" to the clipboard!'):format(result))
end, { desc = "Docu[m]ent [y]ank path" })

vim.keymap.set("n", "<leader>me", "<cmd>e!<CR>", { desc = "Reload buffer discarding changes" })

vim.keymap.set({ "n", "x" }, "<leader>mf", function()
  LazyVim.format({ force = true })
end, { desc = "[F]ormat file or range" })
