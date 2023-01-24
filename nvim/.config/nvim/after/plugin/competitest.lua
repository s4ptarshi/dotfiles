local wk = require("which-key")
wk.register({
    ["<leader>t"] = {
        name = "+Competitest",
        a = { "<cmd>CompetiTestAdd<cr>", "Add testcase" },
        e = { "<cmd>CompetiTestEdit<cr>", "Edit testcases" },
        d = { "<cmd>CompetiTestDelete<cr>", "Delete testcases" },
        r = { "<cmd>CompetiTestRun<cr>", "Run and test code" },
        g = { "<cmd>CompetiTestReceive<cr>", "Get testcases" },
    },
})
