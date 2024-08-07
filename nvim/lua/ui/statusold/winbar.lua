local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local fileBlock = {
    init = function(self)
        self.file = vim.api.nvim_buf_get_name(0)
        self.icon, self.color = require("nvim-web-devicons").get_icon_color(self.file,
            vim.fn.fnamemodify(self.file, ":e"), { default = true })
        self.filename = vim.fn.fnamemodify(self.file, ":t") or "[No Name]"
    end,
    {
        provider = function(self)
            return "  " .. self.icon .. "  "
        end,
        hl = function(self)
            return { fg = self.color }
        end
    },
    {
        provider = function(self)
            return self.filename
        end,
        hl = utils.get_highlight("NavicText")
    }
}

return {
    fallthrough = false,
    {
        condition = function()
            return not conditions.is_active()
        end,
        fileBlock
    },
    {
        fileBlock,
        condition = function()
            return require("nvim-navic").is_available()
        end,
        {
            provider = function()
                local navic = require("nvim-navic").get_location({ highlight = true })
                return (string.len(navic) > 0 and "  " or "") .. navic
            end,
            hl = utils.get_highlight("NavicSeparator"),
            update = { "CursorMoved" }
        }
    },
}
