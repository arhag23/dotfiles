local M = {}

M.lsp_configs = {
	lua_ls = {
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
					path = vim.split(package.path, ";"),
				},
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
					},
				},
			},
		},
	},
	rust_analyzer = {},
	typst_lsp = {},
	basedpyright = {
		settings = {
			basedpyright = {
				analysis = {
					typeCheckingMode = "standard",
				},
			},
		},
	},
	html = {
		filetypes = { "html", "htmldjango", "jinja" },
	},
	cssls = {},
}

M.keymaps = {
	{
		mode = "n",
		key = "gd",
		command = function()
			require("telescope.builtin").lsp_definitions({ reuse_win = true })
		end,
		opts = { desc = "Go to definition" },
		has = "definition",
	},
	{
		mode = "n",
		key = "gD",
		command = vim.lsp.buf.declaration,
		opts = { desc = "Go to declaration" },
		has = "declaration",
	},
	{
		mode = "n",
		key = "K",
		command = vim.lsp.buf.hover,
		opts = { desc = "Display hover info" },
		has = "hover",
	},
	{
		mode = "n",
		key = "gK",
		command = vim.lsp.buf.signature_help,
		opts = { desc = "Display signature_help" },
		has = "signatureHelp",
	},
	{
		mode = "i",
		key = "<C-K>",
		command = vim.lsp.buf.signature_help,
		opts = { desc = "Display signature_help" },
		has = "signatureHelp",
	},
	{
		mode = "n",
		key = "gI",
		command = function()
			require("telescope.builtin").lsp_implementations({ reuse_win = true })
		end,
		opts = { desc = "Go to implementation" },
		has = "implementation",
	},
	{
		mode = "n",
		key = "gr",
		command = function()
			require("telescope.builtin").lsp_references()
		end,
		opts = { desc = "Go to references" },
		has = "references",
	},
	{
		mode = "n",
		key = "<Leader>ss",
		command = function()
			require("telescope.builtin").lsp_workspace_symbols()
		end,
		opts = { desc = "Telescope search workspace symbols" },
		has = "workspaceSymbolProvider",
	},
	{
		mode = { "n", "v" },
		key = "<leader>ca",
		command = vim.lsp.buf.code_action,
		opts = { desc = "Code Action" },
		has = "codeAction",
	},
	{
		mode = "n",
		key = "<leader>f",
		command = function()
			vim.lsp.buf.format({ async = true })
		end,
		opts = { desc = "Format file" },
		has = "format",
	},
	{
		mode = "n",
		key = "<leader>rn",
		command = vim.lsp.buf.rename,
		opts = { desc = "Rename" },
		has = "rename",
	},
}

M.kind_icons = {
	Folder = " ",
	File = " ",
	Module = " ",
	Package = " ",
	Namespace = "󰅩 ",
	Interface = " ",
	Struct = " ",
	Class = " ",
	Method = "󰆧 ",
	Property = " ",
	Field = " ",
	Constructor = " ",
	Enum = " ",
	EnumMember = " ",
	Function = "󰊕 ",
	Variable = " ",
	Constant = "󰏿 ",
	Text = "󰉿 ",
	String = "󰉿 ",
	Value = "󰎠 ",
	Number = "󰎠 ",
	Boolean = "◩ ",
	Array = "󰅪 ",
	Object = "󰅩 ",
	Keyword = "󰌋 ",
	Key = "󰌋 ",
	Null = "󰟢 ",
	Unit = " ",
	Color = "󰏘 ",
	Reference = " ",
	TypeParameter = " ",
	Operator = " ",
	Event = " ",
	Snippet = " ",
}

M.hasCapability = function(buffer, method)
	method = method:find("/") and method or "textDocument/" .. method
	local clients = vim.lsp.get_clients({ bufnr = buffer })
	for _, client in ipairs(clients) do
		if client.supports_method(method) then
			return true
		end
	end
	return false
end

M.defaultAttach = function(client, bufnr)
	if client.server_capabilities.documentSymbolProvider then
		require("nvim-navic").attach(client, bufnr)
	end
end

return M
