-- Plugins that improve the code editing and navigating experience

--    Plugins:
--      -> ultimate-autopair.nvim    [autopairs]
--      -> nvim-surround             [surround]
--      -> nvim-neoclip              [clipboard history]
--      -> gitsigns.nvim             [git changes markers]
--      -> nvim-ufo                  [folding config]

return {
    -- ultimate-autopair.nvim [https://github.com/altermo/ultimate-autopair.nvim/tree/v0.6]
    -- Autopair functionality and tabout
    {
        "altermo/ultimate-autopair.nvim",
        event = { "InsertEnter", "CmdlineEnter" },
        branch = "v0.6",
        opts = {
            fastwarp = {
                multiline = false,
                nocursormove = false,
            },
            close = {
                enable = false,
            },
            tabout = {
                enable = true,
                map = "<Tab>",
                cmap = "<Tab>",
                hopout = true,
                do_nothing_if_fail = false,
            },
        },
    },

    -- nvim-surround [https://github.com/kylechui/nvim-surround]
    -- Surround functionality
    {
        "kylechui/nvim-surround",
        event = "LazyFile",
        opts = {
            keymaps = {
                normal = "sa",
                normal_cur = "ssa",
                normal_line = "Sa",
                normal_cur_line = "SSa",
                visual = "s",
                visual_line = "S",
                delete = "sd",
                change = "sc",
                change_line = "Sc",
            },
        },
    },

    -- nvim-neoclip [https://github.com/AckslD/nvim-neoclip.lua]
    -- Clipboard history for yanks
    {
        "AckslD/nvim-neoclip.lua",
        event = "VeryLazy",
        opts = {
            history = 100,
            default_register = "+",
        },
    },

    -- gitsigns.nvim [https://github.com/lewis6991/gitsigns.nvim]
    -- Stores changes for the buffer and also navigation by git changes
    {
        "lewis6991/gitsigns.nvim",
        event = "LazyFile",
        opts = {}
    },


    -- nvim-ufo [https://github.com/kevinhwang91/nvim-ufo]
    -- Adds folding providers and improves fold UI
    {
        "kevinhwang91/nvim-ufo",
        dependencies = {
            "kevinhwang91/promise-async",
        },
        event = { "LazyFile" },
        config = function()
            require("plugins.configs.nvim-ufo")
        end
    },
}
