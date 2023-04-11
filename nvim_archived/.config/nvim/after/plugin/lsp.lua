local lsp = require('lsp-zero')
lsp.preset('recommended')

-- extended snippets
require 'luasnip'.filetype_extend("html", { "ejs" })
require 'luasnip'.filetype_extend("javascript", { "javascriptreact", "javascriptreact-es7", "html" })

-- Fix Undefined global 'vim'
require 'lspconfig'.lua_ls.setup {
    settings = {
        Lua = {
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
        },
    },
}
-- some custom remaps
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})

-- free up tab for tabout
cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})

-- vim does it's best to do these following commands if no lsp is attached to a buffer
--
lsp.on_attach(function(_, bufnr)
    vim.keymap.set("n", "<leader>l", function()
    end,
        { desc = "+lsp" })
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end,
        { buffer = bufnr, remap = false, desc = "definition" })
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { buffer = bufnr, remap = false, desc = "hover" })
    vim.keymap.set("n", "<leader>ls", function() vim.lsp.buf.workspace_symbol() end,
        { buffer = bufnr, remap = false, desc = "workspace symbol" })
    vim.keymap.set("n", "<leader>ld", function() vim.diagnostic.open_float() end,
        { buffer = bufnr, remap = false, desc = "open diagnostic in float" })
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end,
        { buffer = bufnr, remap = false, desc = "go to next diagnostic" })
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end,
        { buffer = bufnr, remap = false, desc = "go to prev diagnostic" })
    vim.keymap.set("n", "<leader>lc", function() vim.lsp.buf.code_action() end,
        { buffer = bufnr, remap = false, desc = "code action" })
    vim.keymap.set("n", "<leader>lr", function() vim.lsp.buf.references() end,
        { buffer = bufnr, remap = false, desc = "references" })
    vim.keymap.set("n", "<leader>ln", function() vim.lsp.buf.rename() end,
        { buffer = bufnr, remap = false, desc = "rename" })
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end,
        { buffer = bufnr, remap = false, desc = "help" })
end)

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})
