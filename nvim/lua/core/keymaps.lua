local M = {}

local map = function(mode, key, command, opts)
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

M.map = map

M.setup = function()
    -- Move lines
    map("n", "<A-j>", "<Cmd>m .+1<CR>==", { silent = true, desc = "Move line down" })
    map("n", "<A-k>", "<Cmd>m .-2<CR>==", { silent = true, desc = "Move line up" })
    map("i", "<A-j>", "<Esc><Cmd>m .+1<CR>==gi", { silent = true, desc = "Move line down" })
    map("i", "<A-k>", "<Esc><Cmd>m .-2<CR>==gi", { silent = true, desc = "Move line up" })
    map("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
    map("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })

    -- Copy lines
    map("n", "<A-J>", "<Cmd>t.<CR>==", { silent = true, desc = "Copy line below" })
    map("n", "<A-K>", "<Cmd>t.-1<CR>==", { silent = true, desc = "Copy line above" })
    map("i", "<A-J>", "<Esc><Cmd>t.-1<CR>==gi", { silent = true, desc = "Copy line below" })
    map("i", "<A-K>", "<Esc><Cmd>t.<CR>==gi", { silent = true, desc = "Copy line above" })
    map("v", "<A-J>", ":t '<-1<CR>gv=gv", { silent = true, desc = "Copy selection below" }) map("v", "<A-K>", ":t '><CR>gv=gv", { silent = true, desc = "Copy selection above" })

    -- Switch windows
    map("n", "<C-h>", "<C-w>h", { desc = "Go to the left window" })
    map("n", "<C-j>", "<C-w>j", { desc = "Go to the lower window" })
    map("n", "<C-k>", "<C-w>k", { desc = "Go to the upper window" })
    map("n", "<C-l>", "<C-w>l", { desc = "Go to the right window" })

    -- Close windows
    map("n", "<Leader>q", "<Cmd>q<CR>", { desc = "Close current window" })
    map("n", "<Leader>qq", "<Cmd>qa<CR>", { desc = "Close all windows" })

    -- Clear search
    map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clears search highlights" })

    -- Select last pasted/changed text
    map("n", "gp", "`[v`]", { desc = "Select last pasted/changed text" })
end

return M
