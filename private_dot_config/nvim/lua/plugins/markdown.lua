return {
	-- In-buffer rendering: headings/code/tables/lists + $...$/$$...$$ math via
	-- pylatexenc's latex2text (installed in the molten venv).
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			latex = {
				enabled = true,
				-- converter = vim.fn.expand("~/.virtualenvs/neovim/bin/latex2text"),
				converter = { "utftex" }, -- vim.fn.expand("ut"),
				position = "center",
			},
		},
		keys = {
			{ "<leader>um", "<cmd>RenderMarkdown toggle<CR>", desc = "toggle markdown rendering" },
		},
	},

	-- Fully graphical preview in the browser (bundles KaTeX + mermaid + images).
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && npm install",
		ft = { "markdown" },
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		keys = {
			{ "<leader>up", "<cmd>MarkdownPreviewToggle<CR>", desc = "markdown preview (browser)" },
		},
	},

	-- Image rendering
	{
		"3rd/image.nvim",
		lazy = false,
		opts = {
			backend = "kitty",
			integrations = {
				markdown = {
					enabled = true,
					only_render_image_at_cursor = true,
				},
			},
			max_width_window_percentage = 80,
		},
	},
}
