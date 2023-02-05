vim.opt.nu = true
vim.opt.relativenumber = true
vim.cmd.colorscheme("catppuccin")
vim.opt.mouse = "a"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true


vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.linebreak = true

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8


vim.opt.cmdheight = 0

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.updatetime = 50

vim.wo.fillchars = 'eob: '

-- whichkey timeout in ms
vim.opt.timeoutlen = 0;

--converts ejs to html for compatibility with lsp and treesitter
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.ejs",
  command = "set filetype=html"
})
