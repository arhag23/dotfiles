local M = {}

--M.colors = require("catppuccin.palettes").get_palette("macchiato")

-- sets highlight without overwriting everything, similar to how :highlight works
M.set_highlight = function(hlGroup, hl)
	local cur = vim.api.nvim_get_hl(0, { name = hlGroup })
	cur = cur == vim.empty_dict and {} or cur
	vim.api.nvim_set_hl(0, hlGroup, vim.tbl_deep_extend("force", cur, hl))
end

M.get_highlight = function(hlGroup)
	return vim.api.nvim_get_hl(0, { name = hlGroup })
end

local hl = M.get_highlight
M.colors = {
	blue = hl("Function").fg,
	green = hl("String").fg,
	purple = hl("Statement").fg,
	orange = hl("Constant").fg,
	red = hl("DiagnosticError").fg,
	light_gray = hl("Comment").fg,
	dark_gray = hl("NonText").fg,
	dark_bg = hl("NormalFloat").bg,
	lightest_bg = hl("PmenuThumb").bg,
	lighter_bg = hl("PmenuSbar").bg,
	light_bg = hl("Pmenu").bg,
	normal_bg = hl("Normal").bg,
	text = hl("Normal").fg,
	linenr = hl("CursorLineNr").fg,
}

return M
