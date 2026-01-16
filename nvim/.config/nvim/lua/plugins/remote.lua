return {
    {
        "amitds1997/remote-nvim.nvim",
        version = "*",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "muniftanjim/nui.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            require("remote-nvim").setup({
                -- Callback to open a new Kitty tab when connection is ready
                client_callback = function(port, _)
                    local cmd = {
                        "kitty",
                        "nvim",
                        "--server",
                        ("localhost:%s"):format(port),
                        "--remote-ui",
                    }

                    vim.fn.jobstart(cmd, {
                        detach = true, -- Ensures the new window isn't tied to the current nvim process
                        on_exit = function(_, exit_code)
                            if exit_code ~= 0 then
                                vim.notify(
                                    ("Kitty client failed with exit code %s"):format(exit_code),
                                    vim.log.levels.ERROR
                                )
                            end
                        end,
                    })
                end,
            })
        end,
    },
}
