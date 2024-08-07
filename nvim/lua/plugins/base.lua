-- Plugins that add or improve important IDE features

--    Plugins:
--      -> toggleterm.nvim    [terminals]
--      -> nvim-ufo           [folding]
--      -> nvim-tree          [file tree]

return {
	-- toggleterm.nvim [https://github.com/akinsho/toggleterm.nvim]
	-- Allows for the creation and maintenance of multiple terminal sessions
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = { "ToggleTerm", "TermExec" },
		keys = { { "<Leader>t", desc = "Toggle terminal" } },
		opts = {
			size = 15,
			hide_numbers = true,
			start_in_insert = true,
			persist_mode = false,
			open_mapping = [[<Leader>t]],
			insert_mappings = false,
			terminal_mappings = false,
			on_create = function(terminal)
				vim.cmd([[setlocal scl=no]]) -- disables sign column
				vim.cmd([[setlocal foldcolumn=0]]) -- disables foldcolumn as well
			end,
		},
	},

	-- nvim-ufo [https://github.com/kevinhwang91/nvim-ufo]
	-- Adds folding providers and improves fold UI
	{
		"kevinhwang91/nvim-ufo",
		dependencies = {
			"kevinhwang91/promise-async",
		},
		event = { "LazyFile" },
		opts = {
			provider_selector = function(_, filetype, buftype)
				return (filetype == "" or buftype == "nofile") and "indent" or { "treesitter", "indent" }
			end,
			preview = {
				win_config = {
					--winblend = 0,
				},
				mappings = {
					scrollU = "<C-k>",
					scrollD = "<C-j>",
				},
			},
			fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate, extra)
				local newVirtText = {}
				local suffix = ("+%d Lines"):format(endLnum - lnum)
				--gets the text from the end of the folded region to display
				local decorator = require("ufo.decorator")
				local wses = decorator.winSessions[extra.winid]
				local fb = wses.foldbuffer
				local namespaces = {}
				for _, ns in pairs(vim.api.nvim_get_namespaces()) do
					if decorator.ns ~= ns then
						table.insert(namespaces, ns)
					end
				end
				local endText = require("ufo.render").captureVirtText(
					extra.bufnr,
					fb:lines(endLnum)[1],
					endLnum,
					fb:syntax() ~= "",
					namespaces,
					wses:concealLevel()
				)
				-- removes whitespace
				if endText[1][1]:match("%s+") == endText[1][1] then
					table.remove(endText, 1)
				end
				local endWidth = 0
				for _, s in ipairs(endText) do
					endWidth = endWidth + vim.fn.strdisplaywidth(s[1])
				end

				local sufWidth = vim.fn.strdisplaywidth(suffix) + 2 + endWidth
				local targetWidth = width - sufWidth
				local curWidth = 0
				for _, chunk in ipairs(virtText) do
					local chunkText = chunk[1]
					local chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if targetWidth > curWidth + chunkWidth then
						table.insert(newVirtText, chunk)
					else
						chunkText = truncate(chunkText, targetWidth - curWidth)
						local hlGroup = chunk[2]
						table.insert(newVirtText, { chunkText, hlGroup })
						chunkWidth = vim.fn.strdisplaywidth(chunkText)
						break
					end
					curWidth = curWidth + chunkWidth
				end
				table.insert(newVirtText, { " ", "UfoFoldedFg" })
				table.insert(newVirtText, { suffix, "UfoFoldedBg" })
				table.insert(newVirtText, { " ", "UfoFoldedFg" })
				for _, chunk in ipairs(endText) do
					table.insert(newVirtText, chunk)
				end
				return newVirtText
			end,
		},
		config = function(_, opts)
			require("ufo").setup(opts)
			require("ui.highlights").set_highlight("Folded", { bg = "" })
			local map = require("core.utils").map
			map("n", "zR", require("ufo").openAllFolds)
			map("n", "zM", require("ufo").closeAllFolds)
			map("n", "zK", function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end)
		end,
	},

	-- nvim-tree [https://github.com/nvim-tree/nvim-tree.lua]
	-- Adds a file explorer sidebar
	{
		"nvim-tree/nvim-tree.lua",
		keys = {
			{ "<Leader>h", "<Cmd>NvimTreeFocus<CR>", mode = "n", desc = "focus file tree" },
		},
		opts = {
			renderer = {
				icons = {
					padding = "  ",
					glyphs = {
						folder = {
							default = "",
							open = "",
						},
						git = {
							unstaged = "✗",
							staged = "✓",
							unmerged = "",
							renamed = "➜",
							untracked = "★",
							deleted = "",
							ignored = "◌",
						},
					},
				},
			},
		},
	},
}
