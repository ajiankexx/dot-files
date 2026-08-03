local translate_dir = vim.fn.expand('~/nvim-plugin/translate.nvim')
return {
    dir = translate_dir,
    lazy = false,
    cond = vim.fn.isdirectory(translate_dir) == 1,
    config = function()
        require("translate").setup({
            model = "Qwen/Qwen2.5-7B-Instruct",
            api_base = "https://api.siliconflow.cn/v1",
            api_key = os.getenv('SILICONFLOW_API_KEY'),
        })
    end,
}
