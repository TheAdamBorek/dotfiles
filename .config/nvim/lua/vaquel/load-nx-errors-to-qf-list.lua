-- Configuration: Update this path to your TypeScript output file
local TSC_OUTPUT_FILE = '/Users/adamborek/Library/Logs/vaquel/nx-last-command-logs.txt'

local runtime_path_mapping = {
  ['@attio/mobile-app'] = 'packages/runtimes/mobile-app/',
  ['@attio/mobile-web-view-harness'] = 'packages/runtimes/mobile-web-view-harness/',
  ['@attio/browser-extension'] = 'packages/runtimes/browser-extension/',
  ['@attio/attio-web'] = 'packages/libraries/react/attio-web/',
  ['@attio/web-containers'] = 'packages/libraries/react/web-containers/',
  ['@attio/awac'] = 'packages/runtimes/awac/',
  ['@attio/browser-extension-sidebar'] = 'packages/runtimes/browser-extension-sidebar/',
  ['@attio/dev-tools-extension'] = 'packages/runtimes/dev-tools-extension/',
  ['@attio/desktop-app'] = 'packages/runtimes/desktop-app/',
  ['@attio/developer-portal'] = 'packages/runtimes/developer-portal/',
  ['@attio/design'] = 'packages/runtimes/design/',
  ['@attio/web-app'] = 'packages/runtimes/web-app/',
  ['@attio/api'] = 'packages/runtimes/api/',
  ['@attio/attio-rich-text'] = 'packages/libraries/react/attio-rich-text/',
  ['@attio/picasso'] = 'packages/libraries/react/picasso/',
  ['@attio/react-utils'] = 'packages/libraries/react/react-utils/',
  ['@attio/web-features'] = 'packages/libraries/react/web-features/',
  ['@attio/mobile-picasso'] = 'packages/libraries/native/mobile-picasso/',
  ['@attio/mobile-picasso-new'] = 'packages/libraries/native/mobile-picasso-new/',
  ['@attio/mobile-features'] = 'packages/libraries/native/mobile-features/',
}

-- Helper function to resolve relative paths
local function resolve_path(package_path, relative_path)
  -- Count how many ../ are in the path
  local up_count = 0
  local rest_path = relative_path

  while rest_path:match '^%.%./' do
    up_count = up_count + 1
    rest_path = rest_path:sub(4) -- Remove '../'
  end

  -- Split package_path into segments
  local segments = {}
  for segment in package_path:gmatch '[^/]+' do
    table.insert(segments, segment)
  end

  -- Go up 'up_count' directories
  for i = 1, up_count do
    table.remove(segments)
  end

  -- Reconstruct the path
  local resolved = table.concat(segments, '/')
  if resolved ~= '' then
    resolved = resolved .. '/'
  end
  resolved = resolved .. rest_path

  return resolved
end

-- Parse TypeScript output into quickfix entries
local function parse_tsc_output(lines)
  local qf_entries = {}
  local current_workspace = nil
  local current_entry = nil
  local unknown_workspaces = {}

  -- Pattern for error lines: path/file.ts(line,col): error message
  -- Paths can be either relative (../../...) or direct (src/...)
  local error_pattern = '^([^%(]+%.%w+)%((%d+),(%d+)%)%: (.*)$'

  -- Pattern for continuation lines (indented or non-command lines)
  local continuation_pattern = '^%s+(.+)$'

  for _, line in ipairs(lines) do
    -- Check for typescript target header
    local workspace, target = line:match '^> nx run (@[^:]+):([^%s]+)'

    -- Only process if it's a typescript target
    local is_typescript_target = target and (target == 'check-typescript' or target == 'build-typescript')

    if workspace and is_typescript_target then
      -- Found a typescript target, set current workspace
      current_workspace = workspace

      -- Flush any pending entry
      if current_entry then
        table.insert(qf_entries, current_entry)
        current_entry = nil
      end
    elseif line:match '^> nx run' then
      -- Different target (not typescript), stop parsing errors
      current_workspace = nil

      -- Flush any pending entry
      if current_entry then
        table.insert(qf_entries, current_entry)
        current_entry = nil
      end
    elseif current_workspace then
      -- We're in a typescript target context, try to parse error lines
      local filename, lnum, col, msg = line:match(error_pattern)

      if filename and lnum and col and msg then
        -- Flush previous entry
        if current_entry then
          table.insert(qf_entries, current_entry)
        end

        -- Resolve the path
        local package_path = runtime_path_mapping[current_workspace]
        if package_path then
          local resolved_path = resolve_path(package_path, filename)

          current_entry = {
            filename = resolved_path,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = msg,
          }
        else
          -- Unknown workspace
          if not vim.tbl_contains(unknown_workspaces, current_workspace) then
            table.insert(unknown_workspaces, current_workspace)
          end
          current_entry = nil
        end
      else
        -- Check if it's a continuation line
        local continuation_text = line:match(continuation_pattern)
        if continuation_text and current_entry then
          current_entry.text = current_entry.text .. ' ' .. continuation_text
        elseif line ~= '' and current_entry then
          -- Non-empty, non-matching line - might be continuation without indent
          current_entry.text = current_entry.text .. ' ' .. line
        end
      end
    end
  end

  -- Flush the last entry
  if current_entry then
    table.insert(qf_entries, current_entry)
  end

  return qf_entries, unknown_workspaces
end

-- Load TypeScript errors from file and populate quickfix list
local function load_nx_errors_to_qf_list()
  -- Check if file exists
  if vim.fn.filereadable(TSC_OUTPUT_FILE) == 0 then
    vim.notify('TypeScript output file not found: ' .. TSC_OUTPUT_FILE, vim.log.levels.ERROR, {
      timeout = 5000,
    })
    return
  end

  -- Read file
  local lines = vim.fn.readfile(TSC_OUTPUT_FILE)

  -- Parse errors
  local qf_entries, unknown_workspaces = parse_tsc_output(lines)

  -- Set quickfix list
  vim.fn.setqflist({}, ' ', {
    title = 'TypeScript Errors',
    items = qf_entries,
  })

  -- Open quickfix if there are errors
  if #qf_entries > 0 then
    vim.cmd 'copen'
  end

  -- Show notifications
  if #unknown_workspaces > 0 then
    vim.notify('Unknown workspace mappings: ' .. table.concat(unknown_workspaces, ', '), vim.log.levels.WARN, { timeout = 5000 })
  end

  vim.notify(string.format('Loaded %d TypeScript errors from file', #qf_entries), vim.log.levels.INFO, { timeout = 3000 })
end

return load_nx_errors_to_qf_list
