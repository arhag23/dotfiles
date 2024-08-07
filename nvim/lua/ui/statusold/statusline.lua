local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local catColors = require("catppuccin.palettes").get_palette("macchiato")

local colors = {
    modeNormal = catColors.blue,
    modeInsert = catColors.green,
    modeTerminal = catColors.green,
    modeCommand = catColors.peach,
    modeVisual = catColors.mauve,
    modeReplace = catColors.red,
    modeText = catColors.base,
    separate1 = catColors.overlay0,
    filename = catColors.surface0,
    filefolder = catColors.surface1,
    background = catColors.crust,
    filetext = catColors.subtext1,
    filepos = catColors.maroon,
    lspcolor = catColors.overlay2,
    diagError = catColors.red,
    diagWarn = catColors.yellow,
    diagHint = catColors.green,
    diagInfo = catColors.blue
}

--separator right of text
local function genSepRight(color)
    local sep = {
        provider = "",
        hl = { fg = color, sp = color, underline = true }
    }
    return sep
end

--separator left of text
local function genSepLeft(color)
    local sep = {
        provider = "",
        hl = { fg = color },
    }
    return sep
end

--solid block separator
local function genSolidSep(color)
    local sep = {
        provider = "█",
        hl = { fg = color, sp = color, underline = true },
    }
    return sep
end

--component showing the mode
local vimMode = {
    provider = function(self)
        return "   %2(" .. self.modes[vim.api.nvim_get_mode().mode][1] .. "%) "
    end,
    hl = function(self)
        return { bg = self:getModeColor(), fg = colors.modeText, bold = true, }
    end,
    update = { "ModeChanged", },
    genSepRight(colors.separate1)
}

--components for showing file name and icon
local fileInfo = {
    init = function(self)
        self.file = vim.api.nvim_buf_get_name(0)
    end,
    hl = { bg = colors.filefolder }
}

local fileFolder = {
    init = function(self)
        self.folder = vim.fn.fnamemodify(self.file, ":.:h")
        if self.folder == "." then self.folder = vim.fn.fnamemodify(self.file, ":p:h:t") end
        if not conditions.width_percent_below(#self.folder, 0.2) then
            self.folder = vim.fn.pathshorten(self.folder)
        end
    end,
    provider = function(self)
        return "   " .. self.folder .. " "
    end,
    hl = { bg = colors.filefolder },
    genSepRight(colors.filename),
}

local fileIcon = {
    init = function(self)
        self.icon, self.color = require("nvim-web-devicons").get_icon_color(self.file, vim.fn.fnamemodify(self.file, ":e"), { default = true })
    end,
    provider = function(self)
        return " " .. self.icon .. "  "
    end,
    hl = function(self)
        return { fg = self.color, bg = colors.filename }
    end
}

local fileName = {
    init = function(self)
        self.filename = vim.fn.fnamemodify(self.file, ":t")
        if self.filename == "" then self.filename = "[No Name]" end
    end,
    provider = function(self)
        return self.filename .. " "
    end,
    hl = { bg = colors.filename },
    genSepRight(colors.background),
}

fileInfo = utils.insert(fileInfo, genSepLeft(colors.separate1), fileFolder, fileIcon, fileName)

local diagnostics = {
    condition = conditions.has_diagnostics,
    update = { "DiagnosticChanged", "BufEnter" },
    static = {
        error_icon = "  ",
        warn_icon = "  ",
        hint_icon = " ",
        info_icon = "  "
    },
    init = function(self)
        self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
        self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,
    {
        provider = " "
    },
    {
        provider = function(self)
            return self.errors > 0 and (self.error_icon .. self.errors .. " ")
        end,
        hl = { fg = colors.diagError }
    },
    {
        provider = function(self)
            return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
        end,
        hl = { fg = colors.diagWarn }
    },
    {
        provider = function(self)
            return self.info > 0 and (self.info_icon .. self.info .. " ")
        end,
        hl = { fg = colors.diagInfo }
    },
    {
        provider = function(self)
            return self.hints > 0 and (self.hint_icon .. self.hints .. " ")
        end,
        hl = { fg = colors.diagHint }
    },
    on_click = {
        callback = function()
            require("trouble").toggle({ mode = "document_diagnostics" })
        end,
        name = "heirline_diagnostic"
    }
}

local fill = {
    provider = "%=",
}

local LSPActive = {
    condition = conditions.lsp_attached,
    update = { "LspAttach", "LspDetach" },
    provider = function()
        local names = {}
        for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
            table.insert(names, server.name)
        end
        return "  LSP: [" .. table.concat(names, ", ") .. "] "
    end,
    hl = { fg = colors.lspcolor }
}

local filePos = {
    genSepLeft(colors.background),
    {
        provider = "  %l:%c  ",
    },
    hl = function(self)
        return { bg = self:getModeColor(), fg = colors.modeText, bold = true }
    end,
    update = { "ModeChanged" }
}

local statusLine = {
    hl = { bg = colors.background },
    static = {
        modes = {
            ["n"] = { "NORMAL", "St_NormalMode" },
            ["niI"] = { "NORMAL i", "St_NormalMode" },
            ["niR"] = { "NORMAL r", "St_NormalMode" },
            ["niV"] = { "NORMAL v", "St_NormalMode" },
            ["no"] = { "N-PENDING", "St_NormalMode" },
            ["i"] = { "INSERT", "St_InsertMode" },
            ["ic"] = { "INSERT (completion)", "St_InsertMode" },
            ["ix"] = { "INSERT completion", "St_InsertMode" },
            ["t"] = { "TERMINAL", "St_TerminalMode" },
            ["nt"] = { "NTERMINAL", "St_NormalMode" },
            ["v"] = { "VISUAL", "St_VisualMode" },
            ["V"] = { "V-LINE", "St_VisualMode" },
            ["Vs"] = { "V-LINE (Ctrl O)", "St_VisualMode" },
            ["\22"] = { "V-BLOCK", "St_VisualMode" },
            ["R"] = { "REPLACE", "St_ReplaceMode" },
            ["Rv"] = { "V-REPLACE", "St_ReplaceMode" },
            ["s"] = { "SELECT", "St_SelectMode" },
            ["S"] = { "S-LINE", "St_SelectMode" },
            [""] = { "S-BLOCK", "St_SelectMode" },
            ["c"] = { "COMMAND", "St_CommandMode" },
            ["cv"] = { "COMMAND", "St_CommandMode" },
            ["ce"] = { "COMMAND", "St_CommandMode" },
            ["r"] = { "PROMPT", "St_ConfirmMode" },
            ["rm"] = { "MORE", "St_ConfirmMode" },
            ["r?"] = { "CONFIRM", "St_ConfirmMode" },
            ["x"] = { "CONFIRM", "St_ConfirmMode" },
            ["!"] = { "SHELL", "St_TerminalMode" },
        },
        modeColor = {
            ["St_NormalMode"] = colors.modeNormal,
            ["St_InsertMode"] = colors.modeInsert,
            ["St_TerminalMode"] = colors.modeTerminal,
            ["St_CommandMode"] = colors.modeCommand,
            ["St_VisualMode"] = colors.modeVisual,
            ["St_ReplaceMode"] = colors.modeReplace,
        },
        getModeColor = function(self)
            return self.modeColor[self.modes[vim.api.nvim_get_mode().mode][2]]
        end
    },
    vimMode,
    genSolidSep(colors.separate1),
    fileInfo,
    diagnostics,
    fill,
    LSPActive,
    filePos
}

return statusLine
