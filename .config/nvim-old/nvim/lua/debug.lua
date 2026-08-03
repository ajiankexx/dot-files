local function MyGreetingFunction()
    print("Hello from MyGreetingFunction!")
    vim.notify("This is a notification from MyGreetingFunction!", vim.log.levels.INFO, { title = "My Plugin" })
end

local function GreetWithName(opts)
    local name = opts.fargs[1] or "Guest" -- 获取第一个参数
    local count = tonumber(opts.fargs[2]) or 1 -- 获取第二个参数并转换为数字

    if opts.bang then -- 检查是否有 ! 后缀
        vim.notify("Received bang! Exiting early.", vim.log.levels.WARN)
        return
    end

    for i = 1, count do
        print("Hello, " .. name .. "! (Count: " .. i .. ")")
    end
end

vim.api.nvim_create_user_command(
    "MyGreeting", -- 命令名：你将在 Neovim 命令行中输入的名称，例如 :MyGreeting
    MyGreetingFunction, -- 当命令被调用时执行的 Lua 函数
    {
        -- 命令属性 (可选)
        desc = "Prints a greeting message.", -- 命令描述，会在 :command MyGreeting 等显示
        -- 更多属性可以查看 :help nvim_create_user_command
    }
)

vim.api.nvim_create_user_command(
    "Greet", -- 命令名：:Greet
    GreetWithName, -- 当命令被调用时执行的 Lua 函数
    {
        desc = "Greets a person by name.",
        nargs = "*", -- 接受任意数量的参数 (0 或更多)
        -- nargs = 1, -- 只接受一个参数
        -- nargs = "+", -- 接受一个或多个参数
        -- nargs = "?", -- 接受 0 或 1 个参数
        complete = "file", -- 启用文件路径补全 (如果你需要)
        bang = true, -- 允许命令后加 ! (例如 :Greet!)
    }
)
