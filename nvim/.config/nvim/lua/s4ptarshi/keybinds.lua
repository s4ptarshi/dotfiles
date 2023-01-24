vim.g.mapleader = " "
local wk = require("which-key")

-- write
vim.keymap.set("n", "<leader>w", vim.cmd.w, { desc = "write" })
-- quit
vim.keymap.set("n", "<leader>q", vim.cmd.q, { desc = "quit" })

-- visual mode shift j and k moves the block
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- capital J in normal mode cursor stays in place
vim.keymap.set("n", "J", "mzJ`z")
-- half page up down cursor stays at center
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
--search terms stay in middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- paste over visual doesnt replace copy register
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "paste w/o register" })

-- yank to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "yank to clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "yank line to clipboard" })

-- delete to void register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], {desc = "del to void"})

--fuck Q
vim.keymap.set("n", "Q", "<nop>")

--formatting ig
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "format code" })

--lsp stuff
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

--replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],{desc="replace word under cursor"})

--mark as executable right from neovim
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true,desc="Mark as executable" })


-- Normal --
-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

-- Resize with arrows
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { noremap = true, silent = true })

-- Navigate buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { noremap = true, silent = true,desc="Next buffer" })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { noremap = true, silent = true,desc="Prev buffer" })


-- Visual --
-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })


vim.keymap.set({ "n", "v" }, "<leader>e", "<cmd>NvimTreeToggle<cr>",{desc="open file tree"})


--delete buffer
wk.register({
    ["<leader>b"] = { name = "+buffer", },
    ["<leader>bd"] = {"<cmd>Bdelete!<cr>", "buffer delete"},
    ["<leader>bw"] = {"<cmd>Bwipeout!<cr>", "buffer wipeout"},
})
