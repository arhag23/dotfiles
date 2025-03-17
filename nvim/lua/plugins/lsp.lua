-- Plugins for managing LSPs and related things

--    Plugins:
--      -> nvim-lspconfig    [Default LSP Configs]
--      -> mason.nvim        [LSP Package manager]
--      -> lazydev.nvim      [LuaLS config]


return {
    -- nvim-lspconfig [https://github.com/neovim/nvim-lspconfig]
	-- Helps setup lsp servers easily
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"williamboman/mason-lspconfig.nvim",
				cmd = { "LspInstall", "LspUninstall" },
				config = function()
					local lspNames = {}
					for k, _ in pairs(require("utils.lsp.configs")) do
						table.insert(lspNames, k)
					end
					require("mason-lspconfig").setup({
						ensure_installed = lspNames,
					})
				end,
			},
		},
		event = "LazyFile",
		config = function()
            require("plugins.configs.nvim-lspconfig")
        end,
	},

	-- mason.nvim [https://github.com/williamboman/mason.nvim]
	-- Packaage manager for LSPs, DAPs, Formatters, and Linters
	{
		"williamboman/mason.nvim",
		cmd = {
			"Mason",
			"MasonInstall",
			"MasonUninstall",
			"MasonUninstallAll",
			"MasonLog",
			"MasonUpdate",
			"MasonUpdateAll",
		},
		opts = {
			ui = {
				icons = {
					package_installed = "●",
					package_pending = "",
					package_uninstalled = "○",
				},
			},
		},
	},

    -- lazydev.nvim [https://github.com/folke/lazydev.nvim]
    -- Configuration for LuaLS to support neovim configuration
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    }
}
