local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local M = {}

-- COMPONENTS
M.comp = {}

M.comp.vimMode = {
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

M.comp.fileFolder = {
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

M.comp.fileIcon = {
	init = function(self)
		-- self.icon, self.color = require("nvim-web-devicons").get_icon_color(
		-- 	self.file,
		-- 	vim.fn.fnamemodify(self.file, ":e"),
		-- 	{ default = true }
		-- )
		self.icon, self.color, _ = require("mini.icons").get("extension", vim.fn.fnamemodify(self.file, ":e"))
		self.color = require("utils.ui.highlights").get_highlight(self.color).fg
	end,
	provider = function(self)
		return " " .. self.icon .. "  "
	end,
	hl = function(self)
		return { fg = self.color }
	end,
}

M.comp.fileName = {
	provider = function(self)
		local filename = vim.fn.fnamemodify(self.file, ":t")
		if filename == "" then
			filename = "[No Name]"
		end
		return filename .. " "
	end,
}

M.comp.git = {
	condition = conditions.is_git_repo,
	init = function(self)
		self.status_dict = vim.b.gitsigns_status_dict
	end,
	{
		provider = function(self)
			return "  " .. self.status_dict.head
		end,
	},
	{
		provider = function(self)
			local count = self.status_dict.added or 0
			return count > 0 and ("  " .. count)
		end,
	},
	{
		provider = function(self)
			local count = self.status_dict.removed or 0
			return count > 0 and ("  " .. count)
		end,
	},
	{
		provider = function(self)
			local count = self.status_dict.changed or 0
			return count > 0 and ("  " .. count)
		end,
	},
}

M.comp.filePos = {
	provider = "  %l:%c  ",
}

M.comp.activeLSP = {
	condition = conditions.lsp_attached,
	provider = function()
		local names = {}
		for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
			table.insert(names, server.name)
		end
		return "   LSP: [" .. table.concat(names, ", ") .. "]  "
	end,
}

local diagIco = require("utils.ui.icons").diag

M.comp.diagnostics = {
	condition = conditions.has_diagnostics,
	init = function(self)
		self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
		self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
		self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
	end,
	{
		provider = " ",
	},
	{
		provider = function(self)
			return self.errors > 0 and (diagIco.error .. " " .. self.errors .. " ")
		end,
		hl = utils.get_highlight("DiagnosticError"),
	},
	{
		provider = function(self)
			return self.warnings > 0 and (diagIco.warn .. " " .. self.warnings .. " ")
		end,
		hl = utils.get_highlight("DiagnosticWarn"),
	},
	{
		provider = function(self)
			return self.info > 0 and (diagIco.info .. " " .. self.info .. " ")
		end,
		hl = utils.get_highlight("DiagnosticInfo"),
	},
	{
		provider = function(self)
			return self.hints > 0 and (diagIco.hint .. " " .. self.hints .. " ")
		end,
		hl = utils.get_highlight("DiagnosticHint"),
	},
	-- on_click = {
	-- 	callback = function()
	-- 		require("trouble").toggle({ mode = "document_diagnostics" })
	-- 	end,
	-- 	name = "heirline_diagnostic",
	-- },
	update = { "DiagnosticChanged", "BufEnter" },
}

M.comp.fileType = {
	provider = function()
		return " 󰅩  " .. vim.bo.filetype .. " "
	end,
}

M.comp.fileEncoding = {
	provider = function()
		return " " .. string.upper(vim.bo.fileencoding) .. " "
	end,
}

-- STATUSLINE

local function join(sep, ...)
	local args = { ... }
	local out = {}

	local extractHl = function(self, tbl)
		return vim.tbl_extend(
			"force",
			self:nonlocal("merged_hl"),
			(type(tbl.hl) == "function" and tbl.hl(self) or tbl.hl) or {}
		)
	end

	for i = 2, #args do
		local sep_tbl = {
			provider = sep,
			hl = function(self)
				return { fg = extractHl(self, args[i - 1]).bg, bg = extractHl(self, args[i]).bg }
			end,
		}
		table.insert(out, args[i - 1])
		table.insert(out, sep_tbl)
	end
	table.insert(out, args[#args])
	return out
end

M.statusline = {
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
	join(
		"",
		utils.clone(M.comp.vimMode, {
			hl = function(self)
				return { fg = "dark_bg", bg = self:getModeColor(), bold = true }
			end,
		}),
		{ provider = " ", hl = { bg = "lightest_bg" } },
		utils.clone(M.comp.fileFolder, { hl = { fg = "text", bg = "lighter_bg" } }),
		{
			utils.clone(M.comp.fileIcon),
			utils.clone(M.comp.fileName),
			hl = { fg = "text", bg = "light_bg" },
		},
		utils.clone(M.comp.git, { hl = { fg = "dark_gray" } }),
		{ provider = "%=" },
		utils.clone(M.comp.diagnostics),
		{
			utils.clone(M.comp.fileEncoding),
			utils.clone(M.comp.fileType),
			utils.clone(M.comp.activeLSP),
			hl = { fg = "dark_gray" },
		},
		utils.clone(M.comp.filePos, {
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

-- STATUSCOLUMN

local foldProv = function()
	local ffi = require("ffi")
	ffi.cdef([[
	    typedef struct {} Error;
	    typedef struct {} win_T;
	    typedef struct {
		    int start;  // line number where deepest fold starts.
		    int level;  // fold level, when zero other fields are N/A.
		    int llevel; // lowest level that starts in v:lnum.
		    int lines;  // number of lines from v:lnum to end of closed fold.
	    } foldinfo_T;
	    foldinfo_T fold_info(win_T* wp, int lnum);
	    win_T *find_window_by_handle(int Window, Error *err);
	    int compute_foldcolumn(win_T *wp, int col);
    ]])
	local fc = vim.opt.fillchars:get()
	return function()
		local wp = ffi.C.find_window_by_handle(0, ffi.new("Error")) -- window pointer
		local foldInfo = ffi.C.fold_info(wp, vim.v.lnum)
		local next_foldInfo = ffi.C.fold_info(wp, vim.v.lnum + 1)
		-- if foldInfo.start == vim.v.lnum then
		-- 	return foldInfo.lines == 0 and fc.foldopen or fc.foldclose
		-- else
		-- 	return " "
		-- end
		if foldInfo.level == 0 then
			return " "
		elseif foldInfo.start == vim.v.lnum then
			return foldInfo.lines == 0 and fc.foldopen or fc.foldclose
		elseif foldInfo.level > next_foldInfo.level then
			if next_foldInfo.level == 0 then
				return "╰"
			else
				-- return "├"
				return "╰"
			end
		else
			return "│"
		end
	end
end

M.statuscolumn = {
	condition = function()
		return not conditions.buffer_matches({
			buftype = { "terminal" },
			filetype = { "snacks_dashboard" },
		})
	end,
	{
		provider = "%s%=",
	},
	{
		provider = foldProv(),
		hl = { fg = "dark_gray" },
	},
	{
		provider = " %l ▎ ",
	},
	-- provider = "%s %C %=%l ▎ ",
}

-- WINBAR

M.winbar = {
	fallthrough = false,
	init = function(self)
		self.file = vim.api.nvim_buf_get_name(0)
	end,
	{
		condition = function()
			return not conditions.is_active()
		end,
		{ provider = "%=" },
		M.comp.fileIcon,
		M.comp.fileName,
	},
	{
		condition = function()
			return conditions.is_active()
		end,
		{
			provider = function()
				return string.rep(" ", 7 + string.len(vim.api.nvim_buf_line_count(0)))
			end,
		},
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
		M.comp.fileIcon,
		M.comp.fileName,
		--hl = utils.get_highlight("NavicSeparator"),
	},
	hl = { fg = "text" },
}

-- TABLINE

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

M.comp.fileClose = {
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

M.tabline = {
	TabLineOffset,
	utils.make_buflist(
		{
			init = function(self)
				self.file = vim.api.nvim_buf_get_name(self.bufnr)
			end,
			-- utils.surround({ "  ", " " }, nil, {M.comp.fileIcon, {
			--     provider = function(self)
			--         local maxLen = 15
			--         local filename = vim.fn.fnamemodify(self.file, ":t")
			--         local len = string.len(filename)
			--         if len > maxLen then
			--             return string.sub(filename, 1, maxLen - 2) .. ".."
			--         else
			--             local left = math.floor((maxLen - len) / 2)
			--             local right = maxLen - left - len
			--             return string.rep(" ", left) .. filename .. string.rep(" ", right)
			--         end
			--     end
			-- }}),
			{
				init = function(self)
					self.maxLen = 20
					self.filename = vim.fn.fnamemodify(self.file, ":t")
					local len = string.len(self.filename)
					self.shorten = len > self.maxLen
					self.left = math.floor((self.maxLen - len) / 2)
					self.right = self.maxLen - self.left - len
				end,
				{
					provider = function(self)
						return self.shorten and "" or string.rep(" ", self.left)
					end,
				},
				utils.surround({ "  ", " " }, nil, {
					M.comp.fileIcon,
					{
						provider = function(self)
							return self.shorten and (string.sub(self.filename, 1, self.maxLen - 2) .. "..")
								or self.filename
						end,
					},
				}),
				{
					provider = function(self)
						return self.shorten and "" or string.rep(" ", self.right)
					end,
				},
			},
			-- utils.surround({ "  ", " " }, nil, { M.comp.fileIcon, M.comp.fileName }),
			M.comp.fileClose,
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

return M
