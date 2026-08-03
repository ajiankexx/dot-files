return {
    dir = "~/work/nvim-plugin/translate.nvim",
    lazy = false,
    config = function() 
        require("translate").setup({
            model = "Qwen/Qwen2.5-7B-Instruct",
            api_base = "https://api.siliconflow.cn/v1",
            -- api_key = os.getenv("api_key")
            api_key = "sk-umzejvrfwhjguepaohsjsdmzusmmkrgvhghuxzxiysugfzyx"
        })
    end,
}


