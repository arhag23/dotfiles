require("core.options")
require("core.lazy")
require("core.autocmds")
require("core.keymaps")

require("ui.highlights").set_highlight("VertSplit", { fg = require("ui.highlights").colors.linenr })
require("ui.highlights").set_highlight("CursorLineNr", { bold = true })
