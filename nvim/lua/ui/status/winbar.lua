local comp = require("ui.status.components")
local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

return {
	fallthrough = false,
	init = function(self)
		self.file = vim.api.nvim_buf_get_name(0)
	end,
	{
		condition = function()
			return not conditions.is_active()
		end,
		{ provider = "%=" },
		comp.fileIcon,
		comp.fileName,
	},
	{
		condition = function()
			return conditions.is_active()
		end,
		{
			condition = function()
				return require("nvim-navic").is_available()
			end,
			provider = function()
				local navic = require("nvim-navic").get_location({ highlight = true })
				--return (string.len(navic) > 0 and " " or "") .. navic
				return " " .. navic
			end,
			update = { "CursorMoved" },
		},
		{ provider = "%=" },
		comp.fileIcon,
		comp.fileName,
		--hl = utils.get_highlight("NavicSeparator"),
	},
	hl = { fg = "text" },
}
