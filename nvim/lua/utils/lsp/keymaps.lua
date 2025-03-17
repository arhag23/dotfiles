return {
	{
		mode = "n",
		key = "gd",
		command = function()
			require("telescope.builtin").lsp_definitions({ reuse_win = true })
		end,
		opts = { desc = "Go to definition" },
		has = "definition",
	},
	{
		mode = "n",
		key = "gD",
		command = vim.lsp.buf.declaration,
		opts = { desc = "Go to declaration" },
		has = "declaration",
	},
	{
		mode = "n",
		key = "K",
		command = vim.lsp.buf.hover,
		opts = { desc = "Display hover info" },
		has = "hover",
	},
	{
		mode = "n",
		key = "gK",
		command = vim.lsp.buf.signature_help,
		opts = { desc = "Display signature_help" },
		has = "signatureHelp",
	},
	{
		mode = "i",
		key = "<C-K>",
		command = vim.lsp.buf.signature_help,
		opts = { desc = "Display signature_help" },
		has = "signatureHelp",
	},
	{
		mode = "n",
		key = "gI",
		command = function()
			require("telescope.builtin").lsp_implementations({ reuse_win = true })
		end,
		opts = { desc = "Go to implementation" },
		has = "implementation",
	},
	{
		mode = "n",
		key = "gr",
		command = function()
			require("telescope.builtin").lsp_references()
		end,
		opts = { desc = "Go to references" },
		has = "references",
	},
	{
		mode = "n",
		key = "<Leader>ss",
		command = function()
			require("telescope.builtin").lsp_workspace_symbols()
		end,
		opts = { desc = "Telescope search workspace symbols" },
		has = "workspaceSymbolProvider",
	},
	{
		mode = { "n", "v" },
		key = "<leader>ca",
		command = vim.lsp.buf.code_action,
		opts = { desc = "Code Action" },
		has = "codeAction",
	},
	{
		mode = "n",
		key = "<leader>f",
		command = function()
			vim.lsp.buf.format({ async = true })
		end,
		opts = { desc = "Format file" },
		has = "format",
	},
	{
		mode = "n",
		key = "<leader>rn",
		command = vim.lsp.buf.rename,
		opts = { desc = "Rename" },
		has = "rename",
	},
	{
		mode = "n",
		key = "<leader>d",
		command = vim.diagnostic.open_float,
		opts = { desc = "Show diagnostic under cursor" },
	},
}
