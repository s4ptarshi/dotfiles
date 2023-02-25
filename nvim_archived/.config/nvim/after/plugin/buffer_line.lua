require("bufferline").setup{
	options = {
		close_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
		right_mouse_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
		offsets = { { filetype = "NvimTree", text = "", padding = 1 } },
		separator_style = "slant", -- | "thick" | "thin" | { 'any', 'any' },
		always_show_bufferline = false,
        diagnostic = "nvim_lsp",
	},
}
