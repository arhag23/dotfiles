-- Plugins for developer tools

--    Plugins:
--        -> conform.nvim      [Autoformatting]

return {
	-- conform.nvim [https://github.com/stevearc/conform.nvim]
	-- Range based formatting
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<Leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "n",
				desc = "Format Buffer",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
			},
			format_on_save = {
				timeout_ms = 2000,
				lsp_fallback = true,
			},
		},
	},
}
