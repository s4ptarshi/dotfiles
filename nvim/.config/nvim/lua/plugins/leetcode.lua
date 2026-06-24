return {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "folke/snacks.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
        -- configuration goes here
        arg = "lc",
        lang = "python",
        picker = { provider = "snacks-picker" },
        image_support = true,
        keys = {
            focus_testcases = "[",
            focus_result = "]",
        },
    },
    -- keys = {
    --     { "<leader>cq", "<cmd>Leet<cr>", desc = "LeetCode Menu" },
    --     { "<leader>cr", "<cmd>Leet run<cr>", desc = "LeetCode Run" },
    --     { "<leader>cs", "<cmd>Leet submit<cr>", desc = "LeetCode Submit" },
    --     { "<leader>cx", "<cmd>Leet exit<cr>", desc = "LeetCode Exit" },
    -- },
}
