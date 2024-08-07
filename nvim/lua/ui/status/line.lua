local comp = require("ui.status.components")
local utils = require("heirline.utils")

local function combine(sep, ...)
	local args = { ... }
	local out = {}
	for i = 2, #args do
		table.insert(out, args[i - 1])
		local bgHl = function(self)
			return vim.tbl_extend(
				"force",
				self:nonlocal("merged_hl"),
				(type(args[i - 1].hl) == "function" and args[i - 1].hl(self) or args[i - 1].hl) or {}
			)
		end
		local fgHl = function(self)
			return vim.tbl_extend(
				"force",
				self:nonlocal("merged_hl"),
				(type(args[i].hl) == "function" and args[i].hl(self) or args[i].hl) or {}
			)
		end
		table.insert(out, {
			provider = sep,
			hl = function(self)
				return { fg = fgHl(self).bg, bg = bgHl(self).bg }
			end,
		})
	end
	table.insert(out, args[#args])
	return out
end

local statusline = {
	static = {
		mode_type = {
			["n"] = "normal",
			["niI"] = "normal",
			["niR"] = "normal",
			["niV"] = "normal",
			["no"] = "normal",
			["i"] = "insert",
			["ic"] = "insert",
			["ix"] = "insert",
			["t"] = "terminal",
			["nt"] = "terminal",
			["v"] = "visual",
			["V"] = "visual",
			["Vs"] = "visual",
			["\22"] = "visual",
			["R"] = "replace",
			["Rv"] = "replace",
			["s"] = "visual",
			["S"] = "visual",
			[""] = "visual",
			["c"] = "command",
			["cv"] = "command",
			["ce"] = "command",
			["r"] = "inactive",
			["rm"] = "inactive",
			["r?"] = "inactive",
			["x"] = "inactive",
			["!"] = "inactive",
		},
		mode_color = {
			normal = "blue",
			insert = "green",
			visual = "purple",
			command = "orange",
			replace = "red",
			terminal = "green",
			inactive = "dark_bg",
		},
		getModeColor = function(self)
			return self.mode_color[self.mode_type[vim.api.nvim_get_mode().mode]]
		end,
	},
	init = function(self)
		self.file = vim.api.nvim_buf_get_name(0)
	end,
	hl = { bg = "dark_bg" },
	combine(
		"",
		utils.clone(comp.vimMode, {
			hl = function(self)
				return { fg = "dark_bg", bg = self:getModeColor(), bold = true }
			end,
		}),
		{ provider = " ", hl = { bg = "lightest_bg" } },
		utils.clone(comp.fileFolder, { hl = { fg = "text", bg = "lighter_bg" } }),
		{
			comp.fileIcon,
			comp.fileName,
			hl = { fg = "text", bg = "light_bg" },
		},
		comp.diagnostics
	),
	{ provider = "%=" },
	combine(
		"",
		comp.activeLSP,
		utils.clone(comp.filePos, {
			hl = function(self)
				return { fg = "dark_bg", bg = self:getModeColor(), bold = true }
			end,
			update = {
				"ModeChanged",
				pattern = "*:*",
				callback = vim.schedule_wrap(function()
					vim.cmd("redrawstatus")
				end),
			},
		})
	),
}

return statusline
