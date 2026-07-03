local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- highlight on yank
autocmd("TextYankPost", {
  group = augroup("yank_highlight", { clear = true }),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- trim trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Auto-start a session (via vim-obsession) so tmux-resurrect can restore nvim
-- state on tmux reopen. Only active inside tmux, and only when nvim was launched
-- WITHOUT a session: we start Obsession writing ./Session.vim in the current
-- directory, which resurrect's built-in 'session' strategy restores via `nvim -S`
-- (see ~/.tmux.conf). If launched with `-S <file>` / an existing obsession session,
-- v:this_session / g:this_obsession is already set and this is a no-op, so the
-- same session file keeps being used.
autocmd("VimEnter", {
  group = augroup("tmux_nvim_session", { clear = true }),
  nested = true,
  callback = function()
    -- only bother when running inside a tmux pane (resurrect's domain)
    if not vim.env.TMUX then
      return
    end
    -- already have/track a session (obsession active, or launched with -S)
    if vim.g.this_obsession or (vim.v.this_session and vim.v.this_session ~= "") then
      return
    end
    -- skip transient / embedded editor invocations (git commit/rebase, scratch,
    -- stdin) — we don't want throwaway sessions for those.
    local ft = vim.bo.filetype
    if ft == "gitcommit" or ft == "gitrebase" or ft == "gitconfig" then
      return
    end
    if vim.bo.buftype ~= "" then
      return
    end
    local bufname = vim.api.nvim_buf_get_name(0)
    if
      bufname:match("COMMIT_EDITMSG")
      or bufname:match("MERGE_MSG")
      or bufname:match("git%-rebase%-todo")
      or bufname:match("%.git/")
    then
      return
    end
    -- start tracking ./Session.vim in the cwd (obsession's default with no arg)
    vim.cmd("Obsession")
  end,
})

-- press `q` to close throwaway windows
autocmd("FileType", {
  group = augroup("q_close", { clear = true }),
  pattern = { "help", "qf", "man", "lspinfo", "checkhealth", "startuptime", "query" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true, nowait = true })
  end,
})
