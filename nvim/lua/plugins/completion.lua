-- Plugins for managing and decorating completion menus

--    Plugins:
--      -> blink.cmp         [Completion engine]

return {
	-- blink.cmp [https://github.com/Saghen/blink.cmp]
	-- Autocompletion engine that can handle many sources
	{
		"saghen/blink.cmp",
		-- dependencies = { "L3MON4D3/LuaSnip", version = "v2.*" },
		dependencies = { "rafamadriz/friendly-snippets", "altermo/ultimate-autopair.nvim" },
		version = "*",
		event = { "InsertEnter", "CmdlineEnter" },
		opts = {
			keymap = {
				preset = "enter",
				["<Tab>"] = {
					function(cmp)
						if not cmp.is_visible() then
							return false
						end
						if #require("blink.cmp.completion.list").items == 1 then
							cmp.select_and_accept()
						else
							cmp.select_next()
						end
						return true
					end,
					"snippet_forward",
					"fallback",
				},
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
				["<CR>"] = { "accept", "hide", "fallback" },
			},
			completion = {
				list = {
					selection = { preselect = false, auto_insert = true },
				},
				menu = {
					min_width = 25,
					max_height = 10,
					scrollbar = false,
					-- border = "solid",
					draw = {
						-- treesitter = { "lsp" },
						columns = {
							{ "label", "label_description", gap = 2 },
							{ "kind_icon", gap = 1, "kind" },
						},
						components = {
							label = {
								width = { fill = true, min = 15 },
							},
						},
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 500,
					window = {
						border = "solid",
						min_width = 40,
					},
				},
				-- ghost_text = { enabled = true },
			},
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "normal",
			},
			signature = { enabled = true },
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			cmdline = {
				keymap = {
					preset = "enter",
					["<Tab>"] = {
						"show",
						function(cmp)
							if not cmp.is_visible() then
								return false
							end
							if #require("blink.cmp.completion.list").items == 1 then
								cmp.select_and_accept()
							else
								cmp.select_next()
							end
							return true
						end,
						"fallback",
					},
					["<S-Tab>"] = { "select_prev", "fallback" },
					-- ["<CR>"] = { "fallback" },
				},
				completion = {
					menu = {},
				},
			},
		},
		opts_extend = { "sources.default" },
	},
}
