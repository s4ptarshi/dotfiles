-----------------------------------------------------------
-- Dashboard configuration file
-----------------------------------------------------------

local ascii = require("ascii")

local status_ok, alpha = pcall(require, 'alpha')
if not status_ok then
  return
end

local dashboard = require('alpha.themes.dashboard')


-- header
-- local banner = {
--     "███████╗ █████╗ ██████╗ ███████╗██╗   ██╗██╗███╗   ███╗",
--     "██╔════╝██╔══██╗██╔══██╗██╔════╝██║   ██║██║████╗ ████║",
--     "███████╗███████║██████╔╝███████╗██║   ██║██║██╔████╔██║",
--     "╚════██║██╔══██║██╔═══╝ ╚════██║╚██╗ ██╔╝██║██║╚██╔╝██║",
--     "███████║██║  ██║██║     ███████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
--     "╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
-- }
--
-- dashboard.section.header.val = banner

dashboard.section.header.val = ascii.get_random_global()

-- Menu

dashboard.section.buttons.val = {
    dashboard.button( "e", "  > New file" , ":ene <BAR> startinsert <CR>"),
    dashboard.button( "f", "  > Find file", ":cd $HOME/Workspace | Telescope find_files<CR>"),
    dashboard.button( "r", "  > Recent"   , ":Telescope oldfiles<CR>"),
    dashboard.button( "q", "  > Quit NVIM", ":qa<CR>"),
}


-- Footer

-- Set footer
local fortune = require("alpha.fortune")
dashboard.section.footer.val = fortune()

alpha.setup(dashboard.opts)

-- Disable folding on alpha buffer
vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])
