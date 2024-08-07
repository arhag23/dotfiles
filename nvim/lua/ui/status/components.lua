local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local M = {}

M.vimMode = {
	static = {
		mode_names = {
			["n"] = "NORMAL",
			["niI"] = "NORMAL i",
			["niR"] = "NORMAL r",
			["niV"] = "NORMAL v",
			["no"] = "N-PENDING",
			["i"] = "INSERT",
			["ic"] = "INSERT (completion)",
			["ix"] = "INSERT completion",
			["t"] = "TERMINAL",
			["nt"] = "NTERMINAL",
			["v"] = "VISUAL",
			["V"] = "V-LINE",
			["Vs"] = "V-LINE (Ctrl O)",
			["\22"] = "V-BLOCK",
			["R"] = "REPLACE",
			["Rv"] = "V-REPLACE",
			["s"] = "SELECT",
			["S"] = "S-LINE",
			[""] = "S-BLOCK",
			["c"] = "COMMAND",
			["cv"] = "COMMAND",
			["ce"] = "COMMAND",
			["r"] = "PROMPT",
			["rm"] = "MORE",
			["r?"] = "CONFIRM",
			["x"] = "CONFIRM",
			["!"] = "SHELL",
		},
	},
	provider = function(self)
		return "   %2(" .. self.mode_names[vim.api.nvim_get_mode().mode] .. "%) "
	end,
	update = {
		"ModeChanged",
		pattern = "*:*",
		callback = vim.schedule_wrap(function()
			vim.cmd("redrawstatus")
		end),
	},
}

M.fileInfo = {
	init = function(self)
		self.file = vim.api.nvim_buf_get_name(0)
	end,
}

M.fileFolder = {
	provider = function(self)
		local folder = vim.fn.fnamemodify(self.file, ":.:h")
		if folder == "." then
			folder = vim.fn.fnamemodify(self.file, ":p:h:t")
		end
		if not conditions.width_percent_below(#folder, 0.2) then
			folder = vim.fn.pathshorten(folder)
		end
		return "   " .. folder .. " "
	end,
}

M.fileIcon = {
	init = function(self)
		self.icon, self.color = require("nvim-web-devicons").get_icon_color(
			self.file,
			vim.fn.fnamemodify(self.file, ":e"),
			{ default = true }
		)
	end,
	provider = function(self)
		return " " .. self.icon .. "  "
	end,
	hl = function(self)
		return { fg = self.color }
	end,
}

M.fileName = {
	provider = function(self)
		local filename = vim.fn.fnamemodify(self.file, ":t")
		if filename == "" then
			filename = "[No Name]"
		end
		return filename .. " "
	end,
}

M.fileClose = {
	{
		condition = function(self)
			return not vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
		end,
		provider = " 󰖭 ",
		on_click = {
			callback = function(_, minwid)
				vim.schedule(function()
					vim.api.nvim_buf_delete(minwid, { force = false })
					vim.cmd.redrawtabline()
				end)
			end,
			minwid = function(self)
				return self.bufnr
			end,
			name = "heirline_tabline_bfrclose",
		},
	},
	{
		condition = function(self)
			return vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
		end,
		provider = "  ",
		hl = function(self)
			if self.is_active then
				return { fg = "green" }
			else
				return { fg = "red" }
			end
		end,
	},
}

local diagIco = require("ui.icons").diag

M.diagnostics = {
	condition = conditions.has_diagnostics,
	init = function(self)
		self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
		self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
		self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
	end,
	{
		provider = function(self)
			return self.errors > 0 and (" " .. diagIco.error .. " " .. self.errors)
		end,
		hl = utils.get_highlight("DiagnosticError"),
	},
	{
		provider = function(self)
			return self.warnings > 0 and (" " .. diagIco.warn .. " " .. self.warnings)
		end,
		hl = utils.get_highlight("DiagnosticWarn"),
	},
	{
		provider = function(self)
			return self.info > 0 and (" " .. diagIco.info .. " " .. self.info)
		end,
		hl = utils.get_highlight("DiagnosticInfo"),
	},
	{
		provider = function(self)
			return self.hints > 0 and (" " .. diagIco.hint .. " " .. self.hints)
		end,
		hl = utils.get_highlight("DiagnosticHint"),
	},
	on_click = {
		callback = function()
			require("trouble").toggle({ mode = "document_diagnostics" })
		end,
		name = "heirline_diagnostic",
	},
	update = { "DiagnosticChanged", "BufEnter" },
}

M.activeLSP = {
	condition = conditions.lsp_attached,
	provider = function()
		local names = {}
		for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
			table.insert(names, server.name)
		end
		return "  LSP: [" .. table.concat(names, ", ") .. "] "
	end,
}

M.filePos = {
	provider = "  %l:%c  ",
}

return M
