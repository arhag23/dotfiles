-- Plugins that improve the UI or add important UI elements

--    Plugins:
--      -> mini.animate                 [animations]
--      -> mini.indentscope             [indentline]
--      -> indent-blankline.nvim        [indentlines]
--      -> highlight-undo.nvim          [undo highlight]
--      -> nvim-web-devicons            [devicons]
--      -> noice.nvim                   [cmdline UI]
--      -> which-key.nvim               [keymap help]
--      -> trouble.nvim                 [LSP fix list]
--      -> telescope.nvim               [Search UI]
--      -> telescope-fzf-native.nvim    [Search backend]
--      -> nvim-navic                   [Winbar Breadcrumbs]
--      -> heirline.nvim                [Statusline]
--      -> alpha-nvim                   [Greeter]
--
--    Colorschemes:
--      -> catppuccin

return {
	-- mini.animate [https://github.com/echasnovski/mini.animate]
	-- Animations for cursor movement, smooth scrolling, and window open/close/resize
	{
		"echasnovski/mini.animate",
		version = false,
		event = "VeryLazy",
		opts = function()
			local mouse_scrolled = false
			for _, scroll in ipairs({ "Up", "Down" }) do
				local key = "<ScrollWheel" .. scroll .. ">"
				vim.keymap.set({ "", "i" }, key, function()
					mouse_scrolled = true
					return key
				end, { expr = true })
			end

			return {
				scroll = {
					timing = require("mini.animate").gen_timing.linear({ duration = 150, unit = "total" }),

					subscroll = require("mini.animate").gen_subscroll.equal({
						predicate = function(total_scroll)
							if mouse_scrolled then
								mouse_scrolled = false
								return false
							end
							return total_scroll > 1
						end,
					}),

					cursor = {
						enable = false,
						timing = require("mini.animate").gen_timing.linear({ duration = 50, unit = "total" }),
					},
				},
			}
		end,
	},

	-- mini.indentscope [https://github.com/echasnovski/mini.indentscope]
	-- Animated indentline for current cursor position
	{
		"echasnovski/mini.indentscope",
		version = false,
		event = "LazyFile",
		opts = function()
			return {
				draw = {
					animation = require("mini.indentscope").gen_animation.quadratic({
						easing = "in-out",
						duration = 40,
						unit = "step",
					}),
				},
				options = {
					try_as_border = true,
				},
				--symbol = "⎢",
			}
		end,
		init = function()
			vim.api.nvim_create_autocmd("filetype", {
				pattern = {
					"help",
					"nvim-tree",
					"trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"alpha",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},

	-- indent-blankline.nvim [https://github.com/lukas-reineke/indent-blankline.nvim]
	-- Indentscope lines
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = "LazyFile",
		config = true,
		cond = false,
	},

	-- highlight-undo.nvim [https://github.com/tzachar/highlight-undo.nvim]
	-- Briefly highlights undo/redo changes
	{
		"tzachar/highlight-undo.nvim",
		event = "LazyFile",
		opts = {
			duration = 1500,
			hlgroup = "Search",
			keymaps = {
				{ "n", "u", "undo", {} },
				{ "n", "<C-r>", "redo", {} },
			},
			undo = {},
			redo = {},
		},
		config = function(_, opts)
			opts.undo.hlgroup = opts.hlgroup
			opts.redo.hlgroup = opts.hlgroup
			require("highlight-undo").setup(opts)

			vim.api.nvim_create_autocmd("TextYankPost", {
				desc = "Highlight yanked text",
				pattern = "*",
				callback = function()
					vim.highlight.on_yank({ higroup = opts.hlgroup, timeout = opts.duration })
				end,
			})
		end,
	},

	-- nvim-web-devicons [https://github.com/nvim-tree/nvim-web-devicons]
	-- Utility to fetch icons based on filetype or special name
	{
		"nvim-tree/nvim-web-devicons",
		event = "VeryLazy",
		opts = {
			override = {
				default_icon = { icon = "" },
				txt = { icon = "" },
			},
		},
	},

	-- noice.nvim [https://github.com/folke/noice.nvim]
	-- Floating window cmdline UI, LSP progress, better LSP markdown formatting
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			signature = {
				enabled = false,
			},
			presets = {
				bottom_search = true,
				long_message_to_split = true,
			},
			views = {
				cmdline_popup = {
					border = {
						style = {
							top_left = "",
							top = " ",
							top_right = "",
							left = "",
							right = "",
							bottom_left = "",
							bottom = "",
							bottom_right = "",
						},
						padding = { 1, 3, 2, 3 },
					},
					win_options = {
						winhighlight = {
							FloatBorder = "FloatBorder",
							Normal = "NormalFloat",
							FloatTitle = "CmdlinePopupTitle",
						},
					},
				},
				popup = {
					border = {
						style = "none",
						padding = { 1, 2, 1, 2 },
					},
				},
			},
			cmdline = {
				enabled = true,
				view = "cmdline_popup",
				format = {
					cmdline = { icon = " " },
					lua = { icon = " " },
					Telescope = { pattern = "^:%s*Telescope%s+", icon = " " },
					highlight = { pattern = "^:%s*highlight%s+", icon = " " },
				},
			},
			popupmenu = {
				backend = "cmp",
			},
		},
		config = function(_, opts)
			require("ui.highlights").set_highlight("CmdlinePopupTitle", {
				fg = require("ui.highlights").colors.dark_bg,
				bg = require("ui.highlights").colors.orange,
				bold = true,
			})
			require("noice").setup(opts)
		end,
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},

	-- which-key.nvim [https://github.com/folke/which-key.nvim]
	-- Menu to display potential next keymaps
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			icons = {
				breadcrumb = "»",
				separator = " ",
				group = "+",
			},
		},
	},

	-- trouble.nvim [https://github.com/folke/trouble.nvim]
	-- A nice UI to show LSP diagnostics and their location
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "TroubleToggle", "Trouble" },
		opts = {
			mode = "document_diagnostics",
			signs = {
				error = " ",
				warning = " ",
				hint = " ",
				information = " ",
				other = " ",
			},
		},
	},

	-- telescope.nvim [https://github.com/nvim-telescope/telescope.nvim]
	-- Search and fuzzy find various lists with a nice floating UI
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
			},
			"nvim-telescope/telescope-file-browser.nvim",
		},
		cmd = "Telescope",
		keys = {
			{ "<Leader>ff", "<Cmd>Telescope find_files<CR>", desc = "Telescope find files" },
			{ "<Leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "Telescope find with grep" },
			{ "<Leader>fb", "<Cmd>Telescope buffers<CR>", desc = "Telescope display open buffers" },
			{ "<Leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "Telescope find help tags" },
			{ "<Leader>fk", "<Cmd>Telescope keymaps<CR>", desc = "Telescope find keymaps" },
			{
				"<Leader>fn",
				"<Cmd>Telescope notify<CR>",
				desc = "Telescope display past notifications",
			},
			{
				"<Leader>fc",
				"<Cmd>Telescope neoclip<CR>",
				desc = "Telescope display clipboard history",
			},

			{
				"<Leader>sf",
				"<Cmd>Telescope current_buffer_fuzzy_find<CR>",
				desc = "Telescope fuzzy find current buffer",
			},
		},
		opts = function()
			local actions = require("telescope.actions")
			return {
				defaults = {
					prompt_prefix = "   ",
					mappings = {
						i = {
							["<esc>"] = actions.close,
							["<Tab>"] = actions.move_selection_worse,
							["<S-Tab>"] = actions.move_selection_better,
							["<C-j>"] = actions.preview_scrolling_down,
							["<C-k>"] = actions.preview_scrolling_up,
							["<C-x>"] = actions.select_vertical,
						},
					},
				},
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
					file_browser = {
						--theme = "ivy",
						hijack_netrw = true,
					},
				},
			}
		end,
		config = function(_, opts)
			local hl = require("ui.highlights")
			hl.set_highlight("TelescopePromptPrefix", { fg = hl.colors.red })
			require("telescope").setup(opts)
			require("telescope").load_extension("fzf")
			require("telescope").load_extension("notify")
			require("telescope").load_extension("neoclip")
			require("telescope").load_extension("file_browser")
		end,
	},

	-- nvim-navic [https://github.com/SmiteshP/nvim-navic]
	-- Provides beadcrumbs for winbar from the lsp
	{
		"SmiteshP/nvim-navic",
		event = "VeryLazy",
		config = function()
			require("ui.highlights").set_highlight("NavicText", { fg = require("ui.highlights").colors.linenr })
			local withSpace = {}
			for name, icon in pairs(require("core.util.lsp").kind_icons) do
				withSpace[name] = icon .. " "
			end
			require("nvim-navic").setup({
				icons = withSpace,
				separator = "  ",
			})
		end,
	},

	-- heirline.nvim [https://github.com/rebelot/heirline.nvim]
	-- Provides for statusline, winbar, and statuscolumn configuration
	{
		"rebelot/heirline.nvim",
		event = "UIEnter",
		config = function()
			require("heirline").setup({
				statusline = require("ui.status.line"),
				winbar = require("ui.status.winbar"),
				statuscolumn = require("ui.status.column"),
				tabline = require("ui.status.tabline"),
				opts = {
					disable_winbar_cb = function(args)
						return require("heirline.conditions").buffer_matches({
							buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
							filetype = { "^git.*", "Trouble" },
						}, args.buf)
					end,
					colors = require("ui.highlights").colors,
				},
			})
			vim.api.nvim_create_augroup("Heirline", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function()
					require("heirline.utils").on_colorscheme(require("ui.status.colors"))
				end,
				group = "Heirline",
			})
		end,
	},

	-- alpha.nvim [https://github.com/goolord/alpha-nvim]
	-- Greeter and welcome screen
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			--"nvim-telescope/telescope.nvim",
			--"nvim-lua/plenary.nvim",
			--"nvim-telescope/telescope-file-browser.nvim",
		},
		opts = function()
			local header = {
				type = "text",
				val = {
					[[                                                                       ]],
					[[                                                                     ]],
					[[       ████ ██████           █████      ██                     ]],
					[[      ███████████             █████                             ]],
					[[      █████████ ███████████████████ ███   ███████████   ]],
					[[     █████████  ███    █████████████ █████ ██████████████   ]],
					[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
					[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
					[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
					[[                                                                       ]],
				},
				opts = {
					position = "center",
					hl = "AlphaHeader",
				},
			}

			local function button(desc, action, key)
				local opts = {
					position = "center",
					shortcut = key,
					align_shortcut = "right",
					cursor = 3,
					width = 50,
					keymap = { "n", key, action, { noremap = true, silent = true, nowait = true } },
					hl = "AlphaButtons",
					hl_shortcut = "AlphaShortcut",
				}

				return {
					type = "button",
					val = desc,
					on_press = function()
						vim.api.nvim_feedkeys(key, "t", false)
					end,
					opts = opts,
				}
			end

			return {
				layout = {
					{ type = "padding", val = 4 },
					header,
					{ type = "padding", val = 3 },
					{
						type = "text",
						val = function()
							return os.date("  %A %b %d    %I:%M %p")
						end,
						opts = {
							hl = "AlphaHeaderLabel",
							position = "center",
						},
					},
					{ type = "padding", val = 2 },
					{
						type = "group",
						val = {
							button("   New File", "<Cmd>e<CR>", "n"),
							button("   Find Files", "<Cmd>Telescope find_files<CR>", "f"),
							button("   Update Plugins", "<Cmd> Lazy sync", "u"),
							button(
								"󰒓   Open Config",
								[[<Cmd>lua require("telescope").extensions.file_browser.file_browser({ path = vim.fn.stdpath("config") })<CR>]],
								"c"
							),
							button("   Quit", "<Cmd>q<CR>", "q"),
						},
						opts = {
							spacing = 1,
						},
					},
					{ type = "padding", val = 2 },
					{
						type = "group",
						val = {
							{
								type = "text",
								val = "󰋚  Recent Files",
								opts = {
									position = "center",
									width = 50,
									hl = "AlphaHeaderLabel",
								},
							},
							{
								type = "group",
								val = function()
									return { require("alpha.themes.theta").mru(0, vim.fn.getcwd(), 5) }
								end,
							},
						},
					},
					{ type = "padding", val = 8 },
					{
						type = "text",
						val = function()
							local stats = require("lazy").stats()
							return "  Loaded "
								.. stats.count
								.. " plugins in "
								.. string.format("%2.1f", stats.startuptime)
								.. " ms"
						end,
						opts = {
							position = "center",
							hl = "AlphaFooter",
						},
					},
				},
				opts = {},
			}
		end,
	},

	-- catppuccin [https://github.com/catppuccin/nvim]
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
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
					notify = true,
				},
			})
			vim.cmd([[colorscheme catppuccin]])
		end,
	},
}
