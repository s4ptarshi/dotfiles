-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local wk = require("which-key")

-- capital J in normal mode cursor stays in place
vim.keymap.set("n", "J", "mzJ`z")
-- half page up down cursor stays at center
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- tmuxnavigate
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>")
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>")
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>")
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>")
--search terms stay in middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
--mark as executable right from neovim
vim.keymap.set("n", "<leader>bx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Mark as executable" })
wk.register({
    ["<leader>t"] = {
        name = "+Competitest",
        a = { "<cmd>CompetiTestAdd<cr>", "Add testcase" },
        e = { "<cmd>CompetiTestEdit<cr>", "Edit testcases" },
        d = { "<cmd>CompetiTestDelete<cr>", "Delete testcases" },
        r = { "<cmd>CompetiTestRun<cr>", "Run and test code" },
        g = {
            name = "+fetch from competitive companion",
            t = { "<cmd>CompetiTestReceive testcases<cr>", "Add testcase" },
            p = { "<cmd>CompetiTestReceive problem<cr>", "Add problem" },
            c = { "<cmd>CompetiTestReceive contest<cr>", "Add contest" },
        },
    },
})
