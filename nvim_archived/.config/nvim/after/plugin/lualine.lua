local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed
    }
  end
end
local get_color = require'lualine.utils.utils'.extract_highlight_colors
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {"alpha",},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'filename'},
    lualine_c = { { 'b:gitsigns_head', icon = '' }, { 'diff', icon = '', source = diff_source }, {
        'lsp_progress',
        display_components = {'lsp_client_name', 'spinner', { 'title', 'percentage', 'message' }},
        spinner_symbols = {'⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'},
      }
    },
    lualine_x = {'filetype'},
    lualine_y = {'progress'},
    lualine_z = { {
        'diagnostics',
        symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '},
        colored = true,
        diagnostics_color = {
            error = {fg = get_color("DiagnosticSignError", "fg")},
            warn = {fg = get_color("DiagnosticSignWarn", "fg")},
            info = {fg = get_color("DiagnosticSignInfo", "fg")},
            hint = {fg = get_color("DiagnosticSignHint", "fg")},
            },
        } }
    },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
