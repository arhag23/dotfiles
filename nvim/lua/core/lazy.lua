-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- LazyFile event from LazyVim
local Event = require("lazy.core.handler.event")
Event.mappings.LazyFile = { id = "LazyFile", event = "User", pattern = "LazyFile" }
Event.mappings["User LazyFile"] = Event.mappings.LazyFile

local events = {}
local done = false

local function load()
	if #events == 0 or done then
		return
	end
	done = true
	vim.api.nvim_del_augroup_by_name("lazy_file")

	---@type table<string,string[]>
	local skips = {}
	for _, event in ipairs(events) do
		skips[event.event] = skips[event.event] or Event.get_augroups(event.event)
	end

	vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile", modeline = false })
	for _, event in ipairs(events) do
		if vim.api.nvim_buf_is_valid(event.buf) then
			Event.trigger({
				event = event.event,
				exclude = skips[event.event],
				data = event.data,
				buf = event.buf,
			})
			if vim.bo[event.buf].filetype then
				Event.trigger({
					event = "FileType",
					buf = event.buf,
				})
			end
		end
	end
	vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })
	events = {}
end

-- schedule wrap so that nested autocmds are executed
-- and the UI can continue rendering without blocking
load = vim.schedule_wrap(load)
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePre" }, {
	group = vim.api.nvim_create_augroup("lazy_file", { clear = true }),
	callback = function(event)
		table.insert(events, event)
		load()
	end,
})

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "catppuccin" } },
	ui = {
		-- title = "lazy.nvim",
		icons = {
			cmd = " ",
			config = " ",
			init = " ",
			import = " ",
			keys = " ",
			source = " ",
			task = " ",
		},
	},

	-- automatically check for plugin updates
	-- checker = { enabled = true },
})
