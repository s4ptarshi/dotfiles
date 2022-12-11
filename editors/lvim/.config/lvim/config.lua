-- sap's lvim config
-- general
vim.opt.shiftwidth = 4 -- the number of spaces inserted for each indentation
vim.opt.tabstop = 4 -- insert 2 spaces for a tab
lvim.log.level = "warn"
lvim.format_on_save.enabled = false

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"

-- bufferline shortcuts
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"

-- colorscheme
lvim.colorscheme = "lunar"

-- whichkey keybinds
lvim.builtin.which_key.mappings["n"] = { ":ASToggle<CR>", "Toggle autosave" }
lvim.builtin.which_key.mappings["t"] = {
    name = "+Competitest",
    a = { "<cmd>CompetiTestAdd<cr>", "Add testcase" },
    e = { "<cmd>CompetiTestEdit<cr>", "Edit testcases" },
    d = { "<cmd>CompetiTestDelete<cr>", "Delete testcases" },
    r = { "<cmd>CompetiTestRun<cr>", "Run and test code" },
    g = { "<cmd>CompetiTestReceive<cr>", "Get testcases" },
}

-- plugin config
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false
lvim.builtin.terminal.shell = "/bin/fish"
vim.g.leetcode_browser = 'firefox'

lvim.builtin.treesitter.highlight.enable = true

-- Additional Plugins
lvim.plugins = {
    {
      "Pocco81/auto-save.nvim",
      config = function()
        require("auto-save").setup()
      end,
    },
    {
        'xeluxee/competitest.nvim',
        requires = 'MunifTanjim/nui.nvim',
        config = function()
            require('competitest').setup()
        end
    },
    {
        "karb94/neoscroll.nvim",
        event = "WinScrolled",
        config = function()
            require('neoscroll').setup({
                -- All these keys will be mapped to their corresponding default scrolling animation
                mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>',
                    '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
                hide_cursor = true, -- Hide cursor while scrolling
                stop_eof = true, -- Stop at <EOF> when scrolling downwards
                use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
                respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
                cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
                easing_function = nil, -- Default easing function
                pre_hook = nil, -- Function to run before the scrolling animation starts
                post_hook = nil, -- Function to run after the scrolling animation ends
            })
        end
    },
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup({ "*" }, {
                RGB = true, -- #RGB hex codes
                RRGGBB = true, -- #RRGGBB hex codes
                RRGGBBAA = true, -- #RRGGBBAA hex codes
                rgb_fn = true, -- CSS rgb() and rgba() functions
                hsl_fn = true, -- CSS hsl() and hsla() functions
                css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
                css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
            })
        end,
    },
    { 'p00f/nvim-ts-rainbow', },
    {
        'abecodes/tabout.nvim',
        config = function()
            require('tabout').setup {
                tabkey = '<Tab>', -- key to trigger tabout, set to an empty string to disable
                backwards_tabkey = '<S-Tab>', -- key to trigger backwards tabout, set to an empty string to disable
                act_as_tab = true, -- shift content if tab out is not possible
                act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
                default_tab = '<C-t>', -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
                default_shift_tab = '<C-d>', -- reverse shift default action,
                enable_backwards = true, -- well ...
                completion = true, -- if the tabkey is used in a completion pum
                tabouts = {
                    { open = "'", close = "'" },
                    { open = '"', close = '"' },
                    { open = '`', close = '`' },
                    { open = '(', close = ')' },
                    { open = '[', close = ']' },
                    { open = '{', close = '}' }
                },
                ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
                exclude = {} -- tabout will ignore these filetypes
            }
        end,
        wants = { 'nvim-treesitter' }, -- or require if not used so far
        after = { 'nvim-cmp' } -- if a completion plugin is using tabs load it before
   },
}

-- Autocommands
vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*",
    command = "norm zz"
})
