local function did_run_in_diffview_mode()
  local args = vim.v.argv
  local in_diffview_mode = false
  for _, arg in ipairs(args) do
    if arg == 'DiffviewOpen' then
      in_diffview_mode = true
      break
    end
  end

  return in_diffview_mode
end

Is_diffmode_run = did_run_in_diffview_mode()
if Is_diffmode_run then
  vim.notify 'Running in Diffview mode, auto-session will not be enabled'
end

return {
  'rmagatti/auto-session',
  opts = {
    auto_session_suppress_dirs = { '~/', '~/Developer/', '~/Downloads', '~/Documents', '~/Desktop/' },
    auto_save = not Is_diffmode_run,
    auto_restore = not Is_diffmode_run,
    auto_create = not Is_diffmode_run,
  },
}
