-- Plugins that improve the code editing and navigating experience

--    Plugins:
--      -> ultimate-autopair.nvim         [autopairs]
--      -> nvim-surround                  [surround]
--      -> nvim-neoclip                   [clipboard history]
--      -> nvim-treesitter                [treesitter]
--      -> nvim-treesitter-textobjects    [treesitter textobjects]
--      -> treesj                         [toggle single/multiline codeblock]
--      -> sibling-swap.nvim              [swap sibling nodes]
--      -> ssr.nvim                       [structural search & replace]

return {
	-- ultimate-autopair.nvim [https://github.com/altermo/ultimate-autopair.nvim/tree/v0.6]
	-- Autopair functionality and tabout
	{
		"altermo/ultimate-autopair.nvim",
		event = { "InsertEnter", "CmdlineEnter" },
		branch = "v0.6",
		opts = {
			fastwarp = {
				multiline = false,
				nocursormove = false,
			},
			close = {
				enable = false,
			},
			tabout = {
				enable = true,
				map = "<Tab>",
				cmap = "<Tab>",
				hopout = true,
				do_nothing_if_fail = false,
			},
		},
	},

	-- nvim-surround [https://github.com/kylechui/nvim-surround]
	-- Surround functionality
	{
		"kylechui/nvim-surround",
		event = "LazyFile",
		opts = {
			keymaps = {
				normal = "sa",
				normal_cur = "ssa",
				normal_line = "Sa",
				normal_cur_line = "SSa",
				visual = "s",
				visual_line = "S",
				delete = "sd",
				change = "sc",
				change_line = "Sc",
			},
		},
	},

	-- nvim-neoclip [https://github.com/AckslD/nvim-neoclip.lua]
	-- Clipboard history for yanks
	{
		"AckslD/nvim-neoclip.lua",
		event = "VeryLazy",
		opts = {
			history = 100,
			default_register = "+",
		},
	},

	-- nvim-treesitter [https://github.com/nvim-treesitter/nvim-treesitter]
	-- Improves highlights, provides queries for parsing through files
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		event = { "VeryLazy" },
		opts = {
			ensure_installed = { "lua", "vim", "vimdoc", "c", "cpp", "rust", "python" },
			highlight = {
				enable = true,
			},
			indent = {
				enable = true,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "tn",
					node_incremental = "tn",
					node_decremental = "tN",
				},
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
						["al"] = "@loop.outer",
						["il"] = "@loop.inner",
						["ai"] = "@conditional.outer",
						["ii"] = "@conditional.inner",
						["as"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
					},
					selection_modes = {
						["@parameter.outer"] = "v",
						["@function.outer"] = "V",
						["@class.outer"] = "<C-v>",
					},
					include_surrounding_whitespace = true,
				},
				swap = {
					enable = false,
					swap_next = {
						["<Leader>as"] = "@parameter.inner",
					},
					swap_previous = {
						["<Leader>aS"] = "@parameter.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]m"] = "@function.outer",
						["]c"] = "@class.outer",
						["]l"] = "@loop.outer",
						["]i"] = "@conditional.outer",
						["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
						["]z"] = "@fold",
					},
					goto_next_end = {
						["]M"] = "@function.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
						["[c"] = "@class.outer",
						["[l"] = "@loop.outer",
						["[i"] = "@conditional.outer",
						["[s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
						["[z"] = "@fold",
					},
					goto_previous_end = {
						["[M"] = "@function.outer",
					},
				},
				lsp_interop = {
					enable = true,
					border = "none",
					floating_preview_opts = {},
					peek_definition_code = {
						["Kf"] = "@function.outer",
						["Kc"] = "@class.outer",
					},
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},

	-- treesj [https://github.com/Wansmer/treesj]
	-- Allows you to split or join multiple lines of text
	{
		"Wansmer/treesj",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			{ "tm", "<Cmd>TSJToggle", desc = "Toggle between multiple lines and single line" },
			{ "tjs", "<Cmd>TSJSplit", desc = "Split to multiple lines" },
			{ "tjj", "<Cmd>TSJJoin", desc = "Join to a single line" },
		},
		opts = {
			use_default_keymaps = false,
		},
	},

	-- sibling-swap.nvim [https://github.com/Wansmer/sibling-swap.nvim]
	-- Swaps closest two treesitter nodes
	{
		"Wansmer/sibling-swap.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		keys = function()
			return {
				{ "ts", require("sibling-swap").swap_with_right, desc = "Swap current and next node" },
				{ "tS", require("sibling-swap").swap_with_left, desc = "Swap current and previous node" },
			}
		end,
		opts = {
			use_default_keymaps = false,
			allowed_separators = {
				",",
				";",
				"and",
				"or",
				"&&",
				"&",
				"||",
				"|",
				"==",
				"===",
				"!=",
				"!==",
				"-",
				"+",
				"<",
				"<=",
				">",
				">=",
			},
			highlight_node_at_cursor = { ms = 1500, hl_opts = { link = "Search" } },
		},
	},

	-- ssr.nvim [https://github.com/cshuaimin/ssr.nvim]
	-- Powerful structural search and replace with treesitter and with a nice UI
	{
		"cshuaimin/ssr.nvim",
		keys = {
			{
				"<Leader>sr",
				function()
					require("ssr").open()
				end,
				{ "n", "x" },
				desc = "Structural search and replace",
			},
		},
		opts = {
			border = "none",
			min_width = 50,
			min_height = 5,
			max_width = 120,
			max_height = 25,
			adjust_window = true,
			keymaps = {
				close = "q",
				next_match = "n",
				prev_match = "N",
				replace_confirm = "<cr>",
				replace_all = "<leader><cr>",
			},
		},
	},
}
