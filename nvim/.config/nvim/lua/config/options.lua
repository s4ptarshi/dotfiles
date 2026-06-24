-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- disable swapfile
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- vim.g.clipboard = "osc52"
vim.opt.clipboard = "unnamedplus"

vim.g.vimtex_quickfix_ignore_filters = {
    "Unknown document class",
}
vim.g.molten_image_provider = "image.nvim"
vim.opt.conceallevel = 2
-- Only run this configuration if Neovide is the active UI
if vim.g.neovide then
    -- 1. Font Styling (Requires a Nerd Font installed on your system)
    -- "h15" sets the starting height/size to 15pt
    vim.opt.guifont = "JetBrainsMono Nerd Font:h15"
    -- 2. Visual & Window Enhancements
    vim.g.neovide_opacity = 0.95 -- Slick, slightly transparent window
    vim.g.neovide_scroll_animation_length = 0.3 -- Smooth scrolling time in seconds
    vim.g.neovide_hide_mouse_when_typing = true -- Hides the cursor while you type notes

    -- 3. The Cursor Particle Effects (Choose your vibe)
    -- Options: "railgun", "torpedo", "pixie", "sonic", "bubble", or "" (disabled)
    vim.g.neovide_cursor_animation_length = 0.08 -- Fast, snappy cursor jumps
    vim.g.neovide_cursor_trail_size = 0.4 -- Medium trail length
    vim.g.neovide_cursor_vfx_mode = "railgun" -- Adds subtle particle trails

    -- 4. Font Rendering Polish
    vim.g.neovide_text_gamma = 0.8 -- Adjust text contrast/thickness
    vim.g.neovide_text_contrast = 0.1

    -- 5. Dynamic Font Zooming (Like Obsidian's Ctrl +/-)
    -- This handles zooming the entire editor scale seamlessly
    vim.g.neovide_scale_factor = 1.0

    local change_scale_factor = function(delta)
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
    end

    -- Keybinds: Ctrl + "=" to zoom in, Ctrl + "-" to zoom out
    vim.keymap.set("n", "<C-=>", function()
        change_scale_factor(1.1)
    end, { desc = "Zoom In" })
    vim.keymap.set("n", "<C-->", function()
        change_scale_factor(1 / 1.1)
    end, { desc = "Zoom Out" })
end
