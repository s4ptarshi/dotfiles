-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- capital J in normal mode cursor stays in place
vim.keymap.set("n", "J", "mzJ`z")
-- half page up down cursor stays at center
-- vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- vim.keymap.set("n", "<C-u>", "<C-u>zz")

--search terms stay in middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
--mark as executable right from neovim
vim.keymap.set("n", "<leader>bx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Mark as executable" })

-- Terminal navigation: Jump out of terminal splits easily
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Go to Left Window" })
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Go to Lower Window" })
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Go to Upper Window" })
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Go to Right Window" })
