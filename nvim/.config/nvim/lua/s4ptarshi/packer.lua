-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]
require('packer').init({
    display = {
        open_fn = function()
            return require("packer.util").float {
                border = "solid",
                style = "minimal",
            }
        end,
    },
})

--plugins
return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    use { "catppuccin/nvim", as = "catppuccin" }
    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use 'mbbill/undotree'
    use {
        'VonHeikemen/lsp-zero.nvim',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
        }
    }
    use 'xiyaowong/nvim-transparent'
    use "lukas-reineke/indent-blankline.nvim"
    use "windwp/nvim-autopairs"
    use {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    }
    use { "akinsho/toggleterm.nvim", tag = '*', config = function()
        require("toggleterm").setup()
    end }
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons', -- optional, for file icons
        },
    }
    use { 'akinsho/bufferline.nvim', tag = "v3.*", requires = 'nvim-tree/nvim-web-devicons' }
    use 'famiu/bufdelete.nvim'
    use "folke/which-key.nvim"
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }
    use {
        'xeluxee/competitest.nvim',
        requires = 'MunifTanjim/nui.nvim',
        config = function() require 'competitest'.setup() end
    }
    use {
        'goolord/alpha-nvim',
        config = function()
            require 'alpha'.setup(require 'alpha.themes.dashboard'.config)
        end,
        requires = { 'BlakeJC94/alpha-nvim-fortune' },
    }
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    use 'p00f/nvim-ts-rainbow'
    use { "shortcuts/no-neck-pain.nvim", tag = "*" }
    use({ "MaximilianLloyd/ascii.nvim", requires = {
        "MunifTanjim/nui.nvim"
    } })

    use({
        "ggandor/leap.nvim",
        requires = {
            "tpope/vim-repeat"
        }
    })
    use {
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
    }
end)
