local Job = require 'plenary.job'
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
}

-- Parse TSC output into quickfix entries
local function parse_tsc_output(lines, workspace_name)
  local qf_entries = {}
  local current_entry = nil
  local unknown_path_mappings = {}

  -- For workspace-specific output (doesn't have workspace name in brackets)
  -- Example: src/file.ts(123,45): error TS9999: ...
  local workspace_error_pattern = '^(%S+)%((%d+),(%d+)%)%: (.*)$'

  -- Pattern for a "new error" line with workspace in brackets
  -- Example: [SOME-BRACKET]: src/file.ts(123,45): error TS9999: ...
  local monorepo_error_pattern = '^%[([^%]]+)%]:%s*(%S+)%((%d+),(%d+)%)%: (.*)$'

  -- Pattern for a "continuation" line with workspace in brackets
  -- Example: [SOME-BRACKET]: more error details...
  local monorepo_continuation_pattern = '^%[([^%]]+)%]:%s*(.*)$'

  -- Pattern for a continuation line without workspace
  -- Example: more error details...
  local workspace_continuation_pattern = '^%s+(.*)$'

  for _, line in ipairs(lines) do
    -- Check if it's a workspace-specific error line (without brackets)
    local filename, lnum, col, msg
    local bracket_str

    if workspace_name then
      -- For workspace-specific errors
      filename, lnum, col, msg = line:match(workspace_error_pattern)
      if filename and lnum and col and msg then
        -- If we were building an entry, commit it
        if current_entry then
          table.insert(qf_entries, current_entry)
        end

        -- For workspace-specific errors, we know the path prefix
        local path_prefix = runtime_path_mapping[workspace_name]
        if path_prefix then
          local full_filename = path_prefix .. filename
          current_entry = {
            filename = full_filename,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = msg,
          }
        else
          table.insert(unknown_path_mappings, workspace_name)
        end
      else
        -- Check if it's a continuation for workspace-specific error
        local c_msg = line:match(workspace_continuation_pattern)
        if c_msg and current_entry then
          -- Append to the current entry
          current_entry.text = current_entry.text .. ' ' .. c_msg
        end
      end
    else
      -- For monorepo-wide errors with brackets
      bracket_str, filename, lnum, col, msg = line:match(monorepo_error_pattern)
      if bracket_str and filename and lnum and col and msg then
        -- If we were building an entry, commit it
        if current_entry then
          table.insert(qf_entries, current_entry)
        end

        -- Start a new entry
        local path_prefix = runtime_path_mapping[bracket_str]
        if path_prefix then
          local full_filename = path_prefix .. filename
          current_entry = {
            filename = full_filename,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = '[' .. bracket_str .. ']: ' .. msg,
          }
        else
          table.insert(unknown_path_mappings, bracket_str)
        end
      else
        -- Maybe it's a continuation line with brackets
        local c_bracket_str, c_msg = line:match(monorepo_continuation_pattern)
        if c_bracket_str and c_msg and current_entry then
          -- Append to the current entry, removing the bracket text from the continuation
          current_entry.text = current_entry.text .. ' ' .. c_msg
        elseif current_entry then
          -- Fallback: just append as-is
          current_entry.text = current_entry.text .. ' ' .. line
        end
      end
    end
  end

  -- Flush the last entry
  if current_entry then
    table.insert(qf_entries, current_entry)
  end

  return qf_entries, unknown_path_mappings
end

-- Run TypeScript compilation and fill quickfix list
local function run_test_typescript_and_fill_qf(workspace_name)
  if workspace_name ~= nil and runtime_path_mapping[workspace_name] == nil then
    vim.notify('Unknown yarn workspace name mapping: ' .. workspace_name, vim.log.levels.ERROR, {
      timeout = 5000,
    })
    return
  end

  local notification_message = workspace_name and ('Running yarn workspace ' .. workspace_name .. ' test-typescript...') or 'Running yarn test-typescript...'
  local notification = vim.notify(notification_message, vim.log.levels.WARN, {
    timeout = false,
  })

  -- We'll collect lines here, then parse them after the job finishes
  local lines = {}

  -- Prepare command arguments based on workspace name
  local args
  if workspace_name then
    args = { 'workspace', workspace_name, 'run', 'test-typescript', '--pretty', 'false' }
  else
    args = { 'run', 'test-typescript' }
  end

  -- Create the async job
  local job = Job:new {
    command = 'yarn',
    args = args,

    -- Called for each line of stdout
    on_stdout = function(_, line)
      table.insert(lines, line)
    end,

    -- Called for each line of stderr
    on_stderr = function(_, line)
      table.insert(lines, line)
    end,

    -- When the job finishes, parse lines into quickfix entries
    on_exit = function(_, return_val)
      local qf_entries, unknown_path_mappings = parse_tsc_output(lines, workspace_name)

      vim.schedule(function()
        local title = workspace_name and ('yarn workspace ' .. workspace_name .. ' test-typescript errors') or 'yarn test-typescript errors'

        vim.fn.setqflist({}, ' ', {
          title = title,
          items = qf_entries,
        })

        if #qf_entries > 0 then
          vim.cmd 'copen'
        end

        if #unknown_path_mappings > 0 then
          vim.notify('Unknown path mappings: ' .. table.concat(unknown_path_mappings, ', '), vim.log.levels.WARN, {
            replace = notification,
            timeout = 5000,
          })
        elseif #qf_entries == 0 and #lines > 0 then
          vim.notify('Got 0 tsc errors but some messages seems to be there...' .. return_val .. ',' .. table.concat(lines, '\n', 1, 10), vim.log.levels.ERROR, {
            replace = notification,
            timeout = 5000,
          })
        else
          local success_message = workspace_name
              and string.format('yarn workspace %s test-typescript finished. Number of errors: %d', workspace_name, #qf_entries)
            or string.format('yarn test-typescript finished. Number of errors: %d', #qf_entries)

          vim.notify(success_message, vim.log.levels.INFO, {
            replace = notification,
            timeout = 5000,
          })
        end
      end)
    end,
  }

  job:start()
end

-- Return a function that can accept a workspace name parameter
return function(workspace_name)
  run_test_typescript_and_fill_qf(workspace_name)
end
