return {
  'unblevable/quick-scope',
  config = function()
    -- Optional: Customize quick-scope settings here
    -- vim.g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' }
    vim.cmd [[
                highlight QuickScopePrimary guifg='#fabd2f' gui=bold ctermfg=214 cterm=bold
                highlight QuickScopeSecondary guifg='#ff7a93' gui=bold ctermfg=108 cterm=bold
            ]]
  end,
}
