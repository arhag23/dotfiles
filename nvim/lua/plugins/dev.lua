-- Plugins for developer tools

--    Plugins:
--        -> nvim-lspconfig    [LSP Config]
--        -> mason.nvim        [LSP Package Manager]
--        -> nvim-cmp          [Autocompletion]
--        -> conform.nvim      [Autoformatting]
--        -> nvim-lint         [Linting Diagnostics]

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
					for k, _ in pairs(require("core.util.lsp").lsp_configs) do
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
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}

			for lsp, config in pairs(require("core.util.lsp").lsp_configs) do
				config.capabilities = capabilities
				config.on_attach = config.on_attach or require("core.util.lsp").defaultAttach
				require("lspconfig")[lsp].setup(config)
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local map = require("core.utils").map
					for _, keys in ipairs(require("core.util.lsp").keymaps) do
						if not keys.has or require("core.util.lsp").hasCapability(ev.buf, keys.has) then
							local opts = keys.opts
							opts.silent = opts.silent ~= false
							opts.buffer = ev.buf
							map(keys.mode, keys.key, keys.command, opts)
						end
					end
					vim.diagnostic.config({
						virtual_text = false,
						severity_sort = true,
					})
				end,
			})
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

	-- nvim-cmp [https://github.com/hrsh7th/nvim-cmp]
	-- Autocompletion from various sources
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			{
				"L3MON4D3/LuaSnip",
				version = "v2.*",
				build = "make install_jsregexp",
			},
		},
		event = { "InsertEnter", "CmdlineEnter" },
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local shouldComplete = function()
				local unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				local curline = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
				return col ~= 0 and curline:sub(col, col):match("[%.%w_:]") ~= nil
				--and curline:sub(col + 1, col + 1):match("[]")
			end
			local inString = function(_, _)
				return require("cmp.config.context").in_treesitter_capture("string")
			end
			cmp.setup({
				preselect = cmp.PreselectMode.None,
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<CR>"] = cmp.mapping({
						i = function(fallback)
							if cmp.visible() then
								if cmp.get_active_entry() then
									cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
								else
									cmp.close()
								end
							else
								fallback()
							end
						end,
						s = cmp.mapping.confirm({ select = false }),
						c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
					}),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							if #cmp.get_entries() == 1 then
								cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
							else
								cmp.select_next_item()
							end
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif shouldComplete() then
							--[[
                            --
							cmp.complete()
							if #cmp.get_entries() <= 1 then
								if #cmp.get_entries() == 1 then
									cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
								end
							end
                            --]]
							fallback()
						else
							fallback()
						end
					end, { "i", "s", "c" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s", "c" }),
					["<Esc>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.abort()
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					--{ name = "nvim_lsp_signature_help" },
				}, {
					{ name = "buffer", entry_filter = inString },
					{ name = "path", entry_filter = inString },
				}),
				formatting = {
					format = function(_, vim_item)
						vim_item.kind =
							string.format("%s %s", require("core.util.lsp").kind_icons[vim_item.kind], vim_item.kind)
						return vim_item
					end,
				},
				experimental = {
					--ghost_text = true,
				},
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},

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
				html = { "djlint", "prettier" },
				css = { "prettier" },
				jinja = { "djlint" },
				htmldjango = { "djlint" },
				python = { "ruff_format" },
			},
			format_on_save = {
				timeout_ms = 2000,
				lsp_fallback = true,
			},
		},
	},

	-- nvim-lint [https://github.com/mfussenegger/nvim-lint]
	-- Linter handling through vim.diagnostic
	{
		"mfussenegger/nvim-lint",
		event = { "LazyFile" },
		opts = {
			events = { "BufWritePost", "BufReadPost", "InsertLeave" },
			linters_by_ft = {
				--lua = { "luacheck" },
				python = { "ruff" },
				html = { "djlint" },
				jinja = { "djlint" },
				htmldjango = { "djlint" },
			},
		},
		config = function(_, opts)
			local lint = require("lint")
			lint.linters_by_ft = opts.linters_by_ft

			local lintWrap = function(context)
				lint.try_lint()
			end

			vim.api.nvim_create_autocmd(opts.events, {
				callback = require("core.utils").debounce(100, lintWrap),
			})
		end,
	},
}
