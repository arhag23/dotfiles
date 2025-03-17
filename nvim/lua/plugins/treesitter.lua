-- Plugins based around treesitter text objects

--    Plugins:
--      -> nvim-treesitter                [treesitter]
--      -> nvim-treesitter-textobjects    [treesitter textobjects]
--      -> treesj                         [toggle single/multiline codeblock]
--      -> sibling-swap.nvim              [swap sibling nodes]


return {
    -- nvim-treesitter [https://github.com/nvim-treesitter/nvim-treesitter]
    -- Improves highlights, provides queries for parsing through files
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        event = { "VeryLazy" },
        opts = {
            ensure_installed = { "lua", "vim", "vimdoc", "c", "cpp", "rust", "python" },
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "tn",
                    node_incremental = "tn",
                    node_decremental = "tN",
                },
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                        ["al"] = "@loop.outer",
                        ["il"] = "@loop.inner",
                        ["ai"] = "@conditional.outer",
                        ["ii"] = "@conditional.inner",
                        ["as"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                    },
                    selection_modes = {
                        ["@parameter.outer"] = "v",
                        ["@function.outer"] = "V",
                        ["@class.outer"] = "<C-v>",
                    },
                    include_surrounding_whitespace = true,
                },
                swap = {
                    enable = false,
                    swap_next = {
                        ["<Leader>as"] = "@parameter.inner",
                    },
                    swap_previous = {
                        ["<Leader>aS"] = "@parameter.inner",
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]m"] = "@function.outer",
                        ["]c"] = "@class.outer",
                        ["]l"] = "@loop.outer",
                        ["]i"] = "@conditional.outer",
                        ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                        ["]z"] = "@fold",
                    },
                    goto_next_end = {
                        ["]M"] = "@function.outer",
                    },
                    goto_previous_start = {
                        ["[m"] = "@function.outer",
                        ["[c"] = "@class.outer",
                        ["[l"] = "@loop.outer",
                        ["[i"] = "@conditional.outer",
                        ["[s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                        ["[z"] = "@fold",
                    },
                    goto_previous_end = {
                        ["[M"] = "@function.outer",
                    },
                },
                lsp_interop = {
                    enable = true,
                    border = "none",
                    floating_preview_opts = {},
                    peek_definition_code = {
                        ["Kf"] = "@function.outer",
                        ["Kc"] = "@class.outer",
                    },
                },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },

    -- treesj [https://github.com/Wansmer/treesj]
    -- Allows you to split or join multiple lines of text
    {
        "Wansmer/treesj",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        keys = {
            { "tm", "<Cmd>TSJToggle<CR>", desc = "Toggle between multiple lines and single line" },
            { "tjs", "<Cmd>TSJSplit<CR>", desc = "Split to multiple lines" },
            { "tjj", "<Cmd>TSJJoin<CR>", desc = "Join to a single line" },
        },
        opts = {
            use_default_keymaps = false,
        },
    },

    -- sibling-swap.nvim [https://github.com/Wansmer/sibling-swap.nvim]
    -- Swaps closest two treesitter nodes
    {
        "Wansmer/sibling-swap.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        keys = function()
            return {
                {
                    "ts",
                    function() require("sibling-swap").swap_with_right() end,
                    desc = "Swap current and next node",
                },
                {
                    "tS",
                    function() require("sibling-swap").swap_with_left() end,
                    desc = "Swap current and previous node",
                },
            }
        end,
        opts = {
            use_default_keymaps = false,
            allowed_separators = {
                ",",
                ";",
                "and",
                "or",
                "&&",
                "&",
                "||",
                "|",
                "==",
                "===",
                "!=",
                "!==",
                "-",
                "+",
                "<",
                "<=",
                ">",
                ">=",
            },
            highlight_node_at_cursor = { ms = 1500, hl_opts = { link = "Search" } },
        },
    },
}
