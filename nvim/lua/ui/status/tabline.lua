local utils = require("heirline.utils")
local comp = require("ui.status.components")

local TabLineOffset = {
	condition = function(self)
		local win = vim.api.nvim_tabpage_list_wins(0)[1]
		local bufnr = vim.api.nvim_win_get_buf(win)
		self.winid = win

		if vim.bo[bufnr].filetype == "NvimTree" then
			self.title = "NvimTree"
			return true
		end
	end,

	provider = function(self)
		local title = self.title
		local width = vim.api.nvim_win_get_width(self.winid)
		local pad = math.ceil((width - #title) / 2)
		return string.rep(" ", pad) .. title .. string.rep(" ", pad)
	end,

	hl = function(self)
		if vim.api.nvim_get_current_win() == self.winid then
			return { fg = "text", bg = "light_bg" }
		else
			return { fg = "dark_gray", bg = "normal_bg" }
		end
	end,
}

local Tabpage = {
	provider = function(self)
		return "%" .. self.tabnr .. "T " .. self.tabpage .. " %T"
	end,
	hl = function(self)
		if not self.is_active then
			return { fg = "dark_gray", bg = "normal_bg" }
		else
			return { fg = "text", bg = "light_bg" }
		end
	end,
}

local TabpageClose = {
	provider = "%999X 󰖭 %X",
	hl = { fg = "text", bg = "dark_bg" },
}

local TabPages = {
	-- only show this component if there's 2 or more tabpages
	condition = function()
		return #vim.api.nvim_list_tabpages() >= 2
	end,
	utils.make_tablist(Tabpage),
	TabpageClose,
	hl = { bg = "dark_bg" },
}

local get_bufs = function()
	return vim.tbl_filter(function(bufnr)
		return vim.api.nvim_get_option_value("buflisted", { buf = bufnr })
	end, vim.api.nvim_list_bufs())
end

local buflist_cache = {}

vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufAdd", "BufDelete" }, {
	callback = function()
		vim.schedule(function()
			local buffers = get_bufs()
			for i, v in ipairs(buffers) do
				buflist_cache[i] = v
			end
			for i = #buffers + 1, #buflist_cache do
				buflist_cache[i] = nil
			end

			if #buflist_cache > 1 then
				vim.o.showtabline = 2
			elseif vim.o.showtabline ~= 1 then
				vim.o.showtabline = 1
			end
		end)
	end,
})

return {
	TabLineOffset,
	utils.make_buflist(
		{
			init = function(self)
				self.file = vim.api.nvim_buf_get_name(self.bufnr)
			end,
			utils.surround({ "  ", " " }, nil, { comp.fileIcon, comp.fileName }),
			comp.fileClose,
			hl = function(self)
				return self.is_active and { fg = "text", underline = true, sp = "linenr", bg = "light_bg" }
					or { fg = "dark_gray", bg = "normal_bg" }
			end,
		} --[[, { provider = " ", hl = { fg = "text" } }, { provider = " ", hl = { fg = "text" } }, function()
		return buflist_cache
	end, false]] --
	),
	{ provider = "%=" },
	TabPages,
	hl = { bg = "dark_bg" },
}
