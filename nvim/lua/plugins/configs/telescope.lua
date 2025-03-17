local actions = require("telescope.actions")
local opts =  {
    defaults = {
        prompt_prefix = "   ",
        mappings = {
            i = {
                ["<esc>"] = actions.close,
                ["<Tab>"] = actions.move_selection_worse,
                ["<S-Tab>"] = actions.move_selection_better,
                ["<C-j>"] = actions.preview_scrolling_down,
                ["<C-k>"] = actions.preview_scrolling_up,
                ["<C-x>"] = actions.select_vertical,
            },
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        file_browser = {
            --theme = "ivy",
            hijack_netrw = true,
        },
    },
}

local hl = require("utils.ui.highlights")
hl.set_highlight("TelescopePromptPrefix", { fg = hl.colors.red })

require("telescope").setup(opts)
require("telescope").load_extension("fzf")
-- require("telescope").load_extension("notify")
require("telescope").load_extension("neoclip")
require("telescope").load_extension("file_browser")
