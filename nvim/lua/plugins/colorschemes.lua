-- Plugins that are colorschemes

--    Colorschemes:
--	-> catppuccin

return {
	-- catppuccin [https://github.com/catppuccin/nvim]
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			flavour = "macchiato",
			no_italic = true,
			integrations = {
				mason = true,
				semantic_tokens = true,
				lsp_trouble = true,
				telescope = {
					enabled = true,
					style = "nvchad",
				},
				navic = {
					enabled = true,
					custom_bg = "NONE",
				},
				notify = true
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd([[colorscheme catppuccin]])
		end,
	},
}
