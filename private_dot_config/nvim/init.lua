-- nvim_test — standalone config (no NvChad / starter framework).
-- Run with: NVIM_APPNAME=nvim_test nvim
-- Layout mirrors the old ~/.config/nvim: options / mappings / autocmds + lua/plugins/* + lua/configs/*

vim.g.mapleader = " "
-- localleader is also <space>: grug-far / coq / lean / vimtex buffer-local maps use <localleader>
vim.g.maplocalleader = " "

-- python3 provider lives in the ~/.virtualenvs dir(notebooks / molten remote plugin)
local neovim_venv = vim.fn.expand("~/.virtualenvs/neovim")
if vim.fn.isdirectory(neovim_venv) == 1 then
	vim.g.python3_host_prog = neovim_venv .. "/bin/python"
else
	vim.notify("neovim python venv not found in `~/.virtualenvs/neovim`", vim.log.levels.WARN)
end

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local repo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("options")
require("autocmds")

local lazy_config = require("configs.lazy")
require("lazy").setup({ { import = "plugins" } }, lazy_config)

vim.schedule(function()
	require("mappings")
end)
