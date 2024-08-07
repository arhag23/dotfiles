local map = require("core.utils").map

--map("n", "<Leader>h", "<Cmd>NvimTreeFocus<CR>", { silent = true, desc = "focus file tree" })

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
map("v", "<A-J>", ":t '<-1<CR>gv=gv", { silent = true, desc = "Copy selection below" })
map("v", "<A-K>", ":t '><CR>gv=gv", { silent = true, desc = "Copy selection above" })

-- Switch windows
map("n", "<C-h>", "<C-w>h", { desc = "Go to the left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to the lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to the upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to the right window" })

map("n", "<Leader>q", "<Cmd>q<CR>", { desc = "Close current window" })
map("n", "<Leader>qq", "<Cmd>qa<CR>", { desc = "Close all windows" })

-- Terminal
map("t", "<Esc>", "<C-\\><C-n> ", { desc = "Goes to terminal normal mode" })
map("t", "<Esc><Esc>", "<C-\\><C-n><Cmd>q<CR>", { desc = "Exits the terminal" })
map("t", "<C-h>", "<Cmd>wincmd h<CR>", { desc = "Go to the left window" })
map("t", "<C-j>", "<Cmd>wincmd j<CR>", { desc = "Go to the lower window" })
map("t", "<C-k>", "<Cmd>wincmd k<CR>", { desc = "Go to the upper window" })
map("t", "<C-l>", "<Cmd>wincmd l<CR>", { desc = "Go to the right window" })

-- Other
map("n", "<Leader>l", "<Cmd>Lazy<CR>", {
	desc = "Open Lazy menu",
})

--[[
-- Telescope
map("n", "<Leader>ff", require("telescope.builtin").find_files, { desc = "Telescope find files" })
map("n", "<Leader>fg", require("telescope.builtin").live_grep, { desc = "Telescope find with grep" })
map("n", "<Leader>fb", require("telescope.builtin").buffers, { desc = "Telescope display open buffers" })
map("n", "<Leader>fh", require("telescope.builtin").help_tags, { desc = "Telescope find help tags" })
map("n", "<Leader>fk", require("telescope.builtin").keymaps , { desc = "Telescope find keymaps" })
map("n", "<Leader>fn", require("telescope").extensions.notify.notify , { desc = "Telescope display past notifications" })
map("n", "<Leader>fc", require("telescope").extensions.neoclip.neoclip , { desc = "Telescope display past notifications" })

map("n", "<Leader>sf", require("telescope.builtin").current_buffer_fuzzy_find, { desc = "Telescope fuzzy find current buffer" })

-- Nvim UFO
--
map("n", "zR", require("ufo").openAllFolds)
map("n", "zM", require("ufo").closeAllFolds)
map("n", "zK", function()
    local winid = require("ufo").peekFoldedLinesUnderCursor()
    if not winid then
        vim.lsp.buf.hover()
    end
end)
--]]
