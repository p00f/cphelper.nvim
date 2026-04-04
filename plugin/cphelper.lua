local nvim_create_user_command = vim.api.nvim_create_user_command

nvim_create_user_command("CphReceive", function()
    require("cphelper.receive").receive()
end, {})

nvim_create_user_command("CphStop", function()
    require("cphelper.receive").stop()
end, {})

nvim_create_user_command("CphTest", function(args)
    vim.cmd.lcd({ "%:p:h", mods = { silent = true } })
    require("cphelper.process_tests").process(args.fargs)
end, { nargs = "*" })

nvim_create_user_command("CphRetest", function(args)
    vim.cmd.lcd({ "%:p:h", mods = { silent = true } })
    require("cphelper.process_tests").process_retests(args.fargs)
end, { nargs = "*" })

nvim_create_user_command("CphEdit", function(args)
    vim.cmd.lcd({ "%:p:h", mods = { silent = true } })
    assert(args.fargs[1], "cphelper.nvim: need at least one test case to edit")
    require("cphelper.modify_tc").edittc(args.fargs[1])
end, { nargs = 1 })

nvim_create_user_command("CphDelete", function(args)
    vim.cmd.lcd({ "%:p:h", mods = { silent = true } })
    require("cphelper.modify_tc").deletetc(args.fargs)
end, { nargs = "+" })

local subcommands = { "receive", "stop", "test", "retest", "edit", "delete" }

nvim_create_user_command("Cph", function(args)
    local subcommand = args.fargs[1]
    local rest = vim.list_slice(args.fargs, 2)
    if subcommand == "receive" then
        require("cphelper.receive").receive()
    elseif subcommand == "stop" then
        require("cphelper.receive").stop()
    elseif subcommand == "test" then
        vim.cmd.lcd({ "%:p:h", mods = { silent = true } })
        require("cphelper.process_tests").process(rest)
    elseif subcommand == "retest" then
        vim.cmd.lcd({ "%:p:h", mods = { silent = true } })
        require("cphelper.process_tests").process_retests(rest)
    elseif subcommand == "edit" then
        vim.cmd.lcd({ "%:p:h", mods = { silent = true } })
        assert(rest[1], "cphelper.nvim: need at least one test case to edit")
        require("cphelper.modify_tc").edittc(rest[1])
    elseif subcommand == "delete" then
        vim.cmd.lcd({ "%:p:h", mods = { silent = true } })
        require("cphelper.modify_tc").deletetc(rest)
    else
        vim.notify(
            "cphelper.nvim: unknown subcommand: " .. tostring(subcommand),
            vim.log.levels.ERROR
        )
    end
end, {
    nargs = "+",
    complete = function(arglead, cmdline, _)
        if cmdline:match("^Cph%s+%S*$") then
            return vim.tbl_filter(function(s)
                return vim.startswith(s, arglead)
            end, subcommands)
        end
        return {}
    end,
})

vim.api.nvim_set_hl(0, "CphUnderline", { underline = true })
