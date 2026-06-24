return {
    -- 1. Quarto Integration
    {
        "quarto-dev/quarto-nvim",
        dependencies = {
            "jmbuhr/otter.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        ft = { "quarto", "markdown" },
        opts = {
            lspFeatures = {
                languages = { "python", "r", "bash", "lua", "html" },
                chunks = "all",
                diagnostics = {
                    enabled = true,
                    triggers = { "BufWritePost" },
                },
                completion = {
                    enabled = true,
                },
            },
            codeRunner = {
                enabled = true,
                default_method = "molten", -- This is what ties Quarto's runner to Molten
            },
        },
        config = function(_, opts)
            require("quarto").setup(opts)

            -- As discovered in the video, make sure these use <leader> and not <localleader>
            local runner = require("quarto.runner")
            vim.keymap.set("n", "<leader>rc", runner.run_cell, { desc = "Quarto Run Cell", silent = true })
            vim.keymap.set("n", "<leader>ra", runner.run_above, { desc = "Quarto Run Cell and Above", silent = true })
            vim.keymap.set("n", "<leader>rA", runner.run_all, { desc = "Quarto Run All Cells", silent = true })
            vim.keymap.set("n", "<leader>rl", runner.run_line, { desc = "Quarto Run Line", silent = true })
            vim.keymap.set("v", "<leader>rv", runner.run_range, { desc = "Quarto Run Visual Range", silent = true })
        end,
    },

    -- 2. Otter (Provides LSP inside code blocks)
    {
        "jmbuhr/otter.nvim",
        opts = {},
    },

    -- 3. Molten (Jupyter Execution & Output Management)
    {
        "benlubas/molten-nvim",
        version = "^1.0.0",
        build = ":UpdateRemotePlugins",
        init = function()
            --     -- The specific display settings he settles on to make it behave correctly
            --     vim.g.molten_auto_open_output = false
            --     vim.g.molten_output_win_max_height = 20
            --     vim.g.molten_wrap_output = true
            -- vim.g.molten_virt_text_output = true
            --     vim.g.molten_virt_lines_off_by_1 = true
            --     vim.g.molten_output_show_more = true -- Highlighted in the video for handling large outputs
            --
            vim.g.molten_auto_open_output = false -- Keep this false so windows don't pop up randomly
            vim.g.molten_virt_text_output = true -- Change to false if you are using full image.nvim renders
            vim.g.molten_wrap_output = true
        end,
        keys = {
            { "<leader>mi", "<cmd>MoltenInit<cr>", desc = "Molten Init" },
            { "<leader>md", "<cmd>MoltenDelete<cr>", desc = "Molten Delete Output" },
            { "<leader>mh", "<cmd>MoltenHideOutput<cr>", desc = "Molten Hide Output" },
            { "<leader>ms", "<cmd>MoltenShowOutput<cr>", desc = "Molten Show Output" },
            { "<leader>mo", "<cmd>noautocmd MoltenEnterOutput<cr>", desc = "Molten Enter Output Window" },
        },
    },
    {
        "3rd/image.nvim",
        config = function()
            require("image").setup({
                backend = "kitty",
                -- Add these required fields:
                integrations = {
                    markdown = {
                        enabled = true,
                        clear_in_insert_mode = true,
                        download_remote_images = true,
                        only_render_image_at_cursor = false,
                        floating_windows = true,
                        filetypes = { "markdown", "quarto" },
                    },
                    neorg = {
                        enabled = true,
                        clear_in_insert_mode = true,
                        download_remote_images = true,
                        only_render_image_at_cursor = false,
                        filetypes = { "norg" },
                    },
                },
                kitty_method = "normal", -- Options: "normal", "tmux", "fallback"
                -- Your existing settings:
                max_width = 100,
                max_height = 12,
                max_height_window_percentage = math.huge,
                max_width_window_percentage = math.huge,
                window_overlap_clear_enabled = true,
                window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
            })
        end,
    },
}
