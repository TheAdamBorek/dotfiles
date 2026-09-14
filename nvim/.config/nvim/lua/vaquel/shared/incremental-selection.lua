-- Treesitter incremental selection, ported from the nvim-treesitter `master` branch
-- (`nvim-treesitter.incremental_selection`), which the `main` branch dropped.
--
-- Neovim 0.12 ships `an`/`in` for this (see `:help treesitter-incremental-selection`),
-- but mini.ai claims those keys for its "around/inside next" textobjects, so the old
-- <C-s> / <BS> behaviour is kept here on top of the core `vim.treesitter` API.
local M = {}

---@type table<integer, TSNode[]> selection history per buffer
local selections = {}

-- Forget the history once visual mode is left, so a fresh selection never expands from stale nodes.
vim.api.nvim_create_autocmd('ModeChanged', {
  group = vim.api.nvim_create_augroup('vaquel_incremental_selection', { clear = true }),
  pattern = '[vV\22]*:[^vV\22]*',
  callback = function(ev)
    selections[ev.buf] = nil
  end,
})

---@return integer srow, integer scol, integer erow, integer ecol 0-based, end-exclusive
local function visual_selection_range()
  local _, csrow, cscol = unpack(vim.fn.getpos 'v')
  local _, cerow, cecol = unpack(vim.fn.getpos '.')
  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    return csrow - 1, cscol - 1, cerow - 1, cecol
  end
  return cerow - 1, cecol - 1, csrow - 1, cscol
end

---Visually select `node` (charwise).
---@param node TSNode
local function select_node(node)
  local srow, scol, erow, ecol = node:range()
  if ecol == 0 and erow > srow then
    -- Node ends at the start of a line: select up to the end of the previous line instead.
    erow = erow - 1
    ecol = #vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1]
  end
  if vim.api.nvim_get_mode().mode ~= 'v' then
    vim.cmd 'normal! v'
  end
  vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
  vim.cmd 'normal! o'
  vim.api.nvim_win_set_cursor(0, { erow + 1, math.max(ecol - 1, 0) })
end

---Start a selection with the named node under the cursor.
function M.init_selection()
  local buf = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(buf, nil, { error = false })
  if not parser then
    return
  end
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  -- The highlighter parses lazily, so make sure the tree (injections included) covers the cursor line.
  parser:parse({ row, row + 1 })
  local node = parser:named_node_for_range({ row, col, row, col })
  if not node then
    return
  end
  selections[buf] = { node }
  select_node(node)
end

---Expand the selection to the closest ancestor that covers more than the current selection.
function M.node_incremental()
  local buf = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(buf, nil, { error = false })
  if not parser then
    return
  end
  local root = parser:parse()[1]:root()
  local csrow, cscol, cerow, cecol = visual_selection_range()

  local nodes = selections[buf]
  if not nodes or #nodes == 0 then
    -- No history: start from the node covering the current visual selection.
    local node = root:named_descendant_for_range(csrow, cscol, cerow, cecol)
    if not node then
      return
    end
    nodes = { node }
    selections[buf] = nodes
    local nsrow, nscol, nerow, necol = node:range()
    if not (nsrow == csrow and nscol == cscol and nerow == cerow and necol == cecol) then
      select_node(node)
      return
    end
    -- The selection already covers that node, so expand to its parent right away.
  end

  local node = nodes[#nodes]
  while true do
    local parent = node:parent()
    if not parent or parent == node then
      -- Reached the top of an injected tree: continue in the main tree.
      parent = root:named_descendant_for_range(csrow, cscol, cerow, cecol)
      if not parent or root == node or parent == node then
        select_node(node)
        return
      end
    end
    node = parent
    local nsrow, nscol, nerow, necol = node:range()
    local larger = nsrow < csrow or (nsrow == csrow and nscol < cscol) or nerow > cerow or (nerow == cerow and necol > cecol)
    if larger then
      table.insert(nodes, node)
      select_node(node)
      return
    end
  end
end

---Shrink the selection back to the previously selected node.
function M.node_decremental()
  local nodes = selections[vim.api.nvim_get_current_buf()]
  if not nodes or #nodes < 2 then
    return
  end
  table.remove(nodes)
  select_node(nodes[#nodes])
end

return M
