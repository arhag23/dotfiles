local M = {}

M.map = function(mode, key, command, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	if type(mode) == table then
		for m in mode do
			vim.keymap.set(m, key, command, options)
		end
	else
		vim.keymap.set(mode, key, command, options)
	end
end

M.debounce = function(ms, fn)
	local timer = vim.uv.new_timer()
	return function(...)
		local args = { ... }
		timer:start(ms, 0, function()
			timer:stop()
			vim.schedule_wrap(fn)(unpack(args))
		end)
	end
end

M.event = function(name)
	vim.schedule(function()
		vim.api.nvim_exec_autocmds("User", { pattern = name, modeline = false })
	end)
end

return M
