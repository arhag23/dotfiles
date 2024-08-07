vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = " "

local vim_opts = {
	autoindent = true,
	tabstop = 4, -- show tabs as 4 spaces
	shiftwidth = 4, -- tab is 4 spaces
	softtabstop = 4, -- cursor moves 4 spaces with tab
	expandtab = true, -- replace tabs with spaces

	mouse = "a", -- enable mouse
	number = true, -- gutter has line numbers
	termguicolors = true, -- allows use of full colors
	signcolumn = "yes:1", -- always shows gutter for gitsigns/debug info
	cursorline = true, -- highlights current line
	wrap = true, -- wraps line instead of side scroll
	breakindent = true, -- preserves indent of wrapped line
	linebreak = true, -- avoids wrapping in the middle of a word
	list = false, -- ensures linebreak works
	scrolloff = 5, -- ensures the cursorline will not be too high or low
	smoothscroll = true, -- scrolls smoothly
	clipboard = "unnamedplus", -- uses system clipboard

	timeout = true, -- timeout for whichkey
	timeoutlen = 300, -- timeoutlen for which key
	pumheight = 8, -- maximum elements in popupmenu
	pumwidth = 20, -- minimum width of popupmenu

	hlsearch = true, -- highlights all matching search entries
	ignorecase = true, -- ignores case in search
	smartcase = true, -- cares about caps for first letter

	laststatus = 3, -- one statusline
	showtabline = 2, -- tabline

	splitright = true, -- opens splits to the right

	shell = "fish", -- sets default shell for toggleterm

	foldcolumn = "1",
	foldlevel = 99,
	foldlevelstart = 99,
	foldenable = true,
	fillchars = {
		eob = " ",
		fold = " ",
		foldopen = "󰅀",
		foldclose = "󰅂",
		foldsep = " ",
	},
}

--[[
local diagSigns = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(diagSigns) do
	local name = "DiagnosticSign" .. type
	vim.fn.sign_define(name, { text = icon, texthl = name })
end
--]]

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
})

for i, j in pairs(vim_opts) do
	vim.opt[i] = j
end

vim.filetype.add({
	extension = {
		jinja = "jinja",
		jinja2 = "jinja",
		j2 = "jinja",
	},
})
