local utils = require("heirline.utils")
local conditions = require("heirline.conditions")

local numbers = {
    provider = "%=%l",
}

local diagnostics = {
    provider = "%s",
    on_click = {
        callback = function()
            local lnum = vim.fn.getmousepos().line
            require("trouble").open("document_diagnostics")
            -- add something that takes you to the location of the error
        end,
        name = "statuscol_showdiag"
    }
}

local foldProv = function()
    local ffi = require("ffi")
    ffi.cdef [[
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
    ]]
    local fc = vim.opt.fillchars:get()
    return function()
        local wp = ffi.C.find_window_by_handle(0, ffi.new("Error")) -- window pointer
        local foldInfo = ffi.C.fold_info(wp, vim.v.lnum)
        if foldInfo.start == vim.v.lnum then
            return foldInfo.lines == 0 and fc.foldopen or fc.foldclose
        else
            return " "
        end
    end
end

local fold = {
    provider = foldProv(),
    hl = { fg = require("ui.highlights").colors.lavender, bold = true },
    on_click = {
        callback = function()
            local mousepos = vim.fn.getmousepos()
            local char = vim.fn.screenstring(mousepos.winrow, mousepos.wincol)
            vim.api.nvim_set_current_win(mousepos.winid)
            vim.api.nvim_win_set_cursor(0, { mousepos.line, 0 })
            local fc = vim.opt.fillchars:get()
            if char == fc.foldopen then
                vim.cmd("norm! zc")
            elseif char == fc.foldclose then
                vim.cmd("norm! zo")
            end
        end,
        name = "statuscol_foldtoggle"
    }
}

return {
    condition = function()
        return not conditions.buffer_matches({
            buftype = { "terminal" }
        })
    end,
    diagnostics,
    numbers,
    utils.surround({ " ", " " }, nil, fold)
}
