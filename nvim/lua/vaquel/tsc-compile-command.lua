local Job = require 'plenary.job'
local runtime_path_mapping = {
  ['@attio/mobile-app'] = 'packages/runtimes/mobile-app/',
  ['@attio/browser-extension'] = 'packages/runtimes/browser-extension/',
}

local function run_test_typescript_and_fill_qf()
  local notification = vim.notify('Running yarn test-typescript...', vim.log.levels.WARN, {
    timeout = false,
  })
  -- We'll collect lines here, then parse them after the job finishes
  local lines = {}

  -- 2. Create the async job
  local job = Job:new {
    command = 'yarn',
    args = { 'run', 'test-typescript' },

    -- Called for each line of stdout
    on_stdout = function(_, line)
      table.insert(lines, line)
    end,

    -- Called for each line of stderr (if you want to handle those too)
    on_stderr = function(_, line)
      table.insert(lines, line)
    end,

    -- 3. When the job finishes, parse lines into quickfix entries
    on_exit = function(_, return_val)
      local qf_entries = {}
      local current_entry = nil

      -- Pattern for a "new error" line. Example:
      --   [SOME-BRACKET]: src/file.ts(123,45): error TS9999: ...
      -- Captures:
      --   1 => bracket string (whatever is inside [ ])
      --   2 => filename
      --   3 => line number
      --   4 => column number
      --   5 => error message
      local new_error_pattern = '^%[([^%]]+)%]:%s*(%S+)%((%d+),(%d+)%)%: (.*)$'

      -- Pattern for a "continuation" line:
      --   [SOME-BRACKET]: more error details...
      -- Captures:
      --   1 => bracket string
      --   2 => the rest
      local continuation_pattern = '^%[([^%]]+)%]:%s*(.*)$'
      local unknown_path_mappings = {}

      for _, line in ipairs(lines) do
        local bracket_str, filename, lnum, col, msg = line:match(new_error_pattern)
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
          -- Maybe it's a continuation line
          local c_bracket_str, c_msg = line:match(continuation_pattern)
          if c_bracket_str and c_msg and current_entry then
            -- Append to the current entry, removing the bracket text from the continuation
            current_entry.text = current_entry.text .. ' ' .. c_msg
          elseif current_entry then
            -- Fallback: just append as-is
            current_entry.text = current_entry.text .. ' ' .. line
          end
        end
      end

      -- Flush the last entry
      if current_entry then
        table.insert(qf_entries, current_entry)
      end

      vim.schedule(function()
        vim.fn.setqflist({}, ' ', {
          title = 'yarn test-typescript errors',
          items = qf_entries,
        })
        vim.cmd 'copen'

        if #unknown_path_mappings > 0 then
          vim.notify('Unknown path mappings: ' .. table.concat(unknown_path_mappings, ', '), vim.log.levels.WARN, {
            replace = notification,
            timeout = 5000,
          })
        else
          vim.notify(string.format('yarn test-typescript finished. Number of errors: %d', #qf_entries), vim.log.levels.INFO, {
            replace = notification,
            timeout = 5000,
          })
        end
      end)
    end,
  }

  job:start()
end

return run_test_typescript_and_fill_qf
