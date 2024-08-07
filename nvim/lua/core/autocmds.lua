vim.api.nvim_create_autocmd("FileType", {
	pattern = "alpha",
	callback = function()
		vim.o.showtabline = 0
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "AlphaClosed",
	callback = function()
		vim.o.showtabline = 2
	end,
})
