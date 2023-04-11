local builtin = require('telescope.builtin')
local wk = require("which-key")

wk.register({
  ["<leader>p"] = {
    name = "+telescope",
    f = { builtin.find_files, "Find File" },
    g = { builtin.git_files, "Open Recent File" },
    s = {
            function()
                builtin.grep_string({ search = vim.fn.input("Enter keyword > ") })
            end
            , "find keyword"
    },
  },
})
