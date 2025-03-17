-- Plugins that improve the UI or add important UI elements

--    Plugins:
--      -> which-key.nvim        [keymap help]
--      -> mini.icons            [centralized icons]
--      -> telescope.nvim        [Search UI]
--      -> indent-blankline      [Indent guides]
--      -> noice.nvim            [CMDLine UI]
--      -> heirline.nvim         [Statusline]
--      -> nvim-navic            [Winbar breadcrumbs]
--      -> incline.nvim          [Floating Winbar]
--      -> nvim-notify           [Pretty notifications]
--      -> snacks.nvim           [Dashboard and terminal]

return {
	-- which-key.nvim [https://github.com/folke/which-key.nvim]
	-- Menu to display potential next keymaps
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			icons = {
				breadcrumb = "»",
				separator = "➜",
				-- separator = "  ",
				group = " +",
			},
		},
	},

	-- mini.icons [https://github.com/echasnovski/mini.icons]
	-- Utility to fetch icons for filetypes, lsp, etc
	{
		"echasnovski/mini.icons",
		version = false,
		lazy = "VeryLazy",
		opts = {
			default = {
				file = { glyph = "" },
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
		config = function()
			require("plugins.configs.telescope")
		end,
	},

	-- indent-blankline.nvim [https://github.com/lukas-reineke/indent-blankline.nvim]
	-- Indentation guides for scope
	{
		"lukas-reineke/indent-blankline.nvim",
		dependencies = { "nvim-treesitter" },
		main = "ibl",
		event = "LazyFile",
		opts = {
			indent = { char = "▏" },
			scope = {
				show_start = false,
				show_end = false,
				include = {
					node_type = {
						lua = { "table_constructor" },
					},
				},
			},
		},
	},

	-- noice.nvim [https://github.com/folke/noice.nvim]
	-- Floating window cmdline UI, LSP progress, better LSP markdown formatting
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		enabled = false,
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = false,
				},
			},
			signature = {
				enabled = false,
			},
			presets = {
				-- bottom_search = true,
				long_message_to_split = true,
				-- command_palette = true,
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
				view = "cmdline",
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
			-- require("utils.ui.highlights").set_highlight("CmdlinePopupTitle", {
			-- 	fg = require("utils.ui.highlights").colors.dark_bg,
			-- 	bg = require("utils.ui.highlights").colors.orange,
			-- 	bold = true,
			-- })
			-- vim.g.ui_cmdline_pos = {vim.o.lines / 2 + 1, vim.o.columns / 2 - 24}
			require("noice").setup(opts)
			vim.o.cmdheight = 1
		end,
	},

	-- heirline.nvim [https://github.com/rebelot/heirline.nvim]
	-- Provides for statusline, winbar, and statuscolumn configuration
	{
		"rebelot/heirline.nvim",
		event = "UIEnter",
		config = function()
			require("heirline").setup({
				statusline = require("plugins.configs.heirline").statusline,
				statuscolumn = require("plugins.configs.heirline").statuscolumn,
				-- winbar = require("plugins.configs.heirline").winbar,
				tabline = require("plugins.configs.heirline").tabline,
				opts = {
					disable_winbar_cb = function(args)
						return require("heirline.conditions").buffer_matches({
							buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
							filetype = { "^git.*", "Trouble" },
						}, args.buf)
					end,
					colors = require("utils.ui.highlights").colors,
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

	-- nvim-navic [https://github.com/SmiteshP/nvim-navic]
	-- Provides breadcrumbs for winbar from the lsp
	{
		"SmiteshP/nvim-navic",
		event = "VeryLazy",
		config = function()
			require("utils.ui.highlights").set_highlight(
				"NavicText",
				{ fg = require("utils.ui.highlights").colors.text }
			)
			local withSpace = {}
			for _, name in ipairs(require("mini.icons").list("lsp")) do
				withSpace[name] = require("mini.icons").get("lsp", name)
				-- withSpace[name] = icon .. " "
			end
			require("nvim-navic").setup({
				icons = withSpace,
				separator = "  ",
			})
		end,
	},

	-- incline.nvim [https://github.com/b0o/incline.nvim]
	-- Floating winbar config
	{
		"b0o/incline.nvim",
		event = "UIEnter",
		config = function()
			local helpers = require("incline.helpers")
			local navic = require("nvim-navic")
			require("incline").setup({
				window = {
					padding = 0,
					margin = { horizontal = 0, vertical = 0 },
				},
				render = function(props)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					if filename == "" then
						filename = " [No Name] "
					end
					local hl_to_hex = function(hl)
						return "#" .. string.format("%x", hl)
					end
					local ft_icon, ft_hl = require("mini.icons").get("file", filename)
					local ft_color = hl_to_hex(require("utils.ui.highlights").get_highlight(ft_hl).fg)
					local res = {
						ft_icon and { " ", ft_icon, "  ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) }
							or "",
						" ",
						{ filename, gui = "bold" },
						guibg = hl_to_hex(require("utils.ui.highlights").colors.lighter_bg),
						-- guibg = hl_to_hex(require("utils.ui.highlights").get_highlight("Pmenu").bg),
					}
					if props.focused then
						for _, item in ipairs(navic.get_data(props.buf) or {}) do
							table.insert(res, {
								{ "  ", group = "NavicSeparator" },
								{ item.icon, group = "NavicIcons" .. item.type },
								{ item.name, group = "NavicText" },
							})
						end
					end
					table.insert(res, " ")
					table.insert(res, { " ", guibg = hl_to_hex(require("utils.ui.highlights").colors.normal_bg) })
					return res
				end,
			})
		end,
	},

	-- nvim-notify [https://github.com/rcarriga/nvim-notify]
	-- Beautiful notifications with animations
	{
		"rcarriga/nvim-notify",
		event = "UIEnter",
	},

	-- snacks.nvim [https://github.com/folke/snacks.nvim]
	-- Dashboard configuration and editor terminal
	{
		"folke/snacks.nvim",
		event = "VimEnter",
		keys = {
			{
				"<Leader>t",
				function()
					require("snacks.terminal").toggle()
				end,
				desc = "Toggles terminal",
			},
			{
				"<Leader>to",
				function()
					require("snacks.terminal").open(nil, { create = true })
				end,
				desc = "Opens new terminal",
			},
		},
		opts = {
			dashboard = {
				enabled = true,
				preset = {
					header = [[
                                                                   
      ████ ██████           █████      ██                    
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████]],
				},
				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },
					{ section = "startup" },
				},
			},
			terminal = { enabled = true },
			bigfile = { enabled = false },
			explorer = { enabled = false },
			indent = { enabled = false },
			input = { enabled = false },
			notifier = { enabled = false },
			picker = { enabled = false },
			quickfile = { enabled = false },
			scope = { enabled = false },
			scroll = { enabled = false },
			statuscolumn = { enabled = false },
			words = { enabled = false },
		},
	},
}
