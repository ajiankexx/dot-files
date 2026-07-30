return {
    'Kaiser-Yang/non-ascii.nvim',
    dependencies = {
        -- 推荐
        -- 可以使用 ; 和 , 来重复上一个操作
        -- 你可以查看 nvim-treesitter-textobjects 的文档学习如何配置
        'nvim-treesitter/nvim-treesitter',
        'nvim-treesitter/nvim-treesitter-textobjects',
    },
    opts = {
        word_jump = {
            -- word 文件每行为一个中文词语
            -- 查看 字典转换 部分了解如何生成 word 文件
            word_files = { vim.fn.expand('~/.config/nvim/dict/zh_dict.txt') },
        }
    },
    config = function(_, opts)
        local non_ascii= require('non-ascii')
        non_ascii.setup(opts)
        local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')
        local next_word, prev_word = ts_repeat_move.make_repeatable_move_pair(
            non_ascii.w,
            non_ascii.b
        )
        local next_end_word, prev_end_word = ts_repeat_move.make_repeatable_move_pair(
            non_ascii.e,
            non_ascii.ge
        )
        vim.keymap.set({ 'n', 'x', 'o' }, 'w', next_word, { desc = 'Next word' })
        vim.keymap.set({ 'n', 'x', 'o' }, 'b', prev_word, { desc = 'Previous word' })
        vim.keymap.set({ 'n', 'x', 'o' }, 'e', next_end_word, { desc = 'Next end word' })
        vim.keymap.set({ 'n', 'x', 'o' }, 'ge', prev_end_word, { desc = 'Previous end word' })
        -- 如果你不使用 nvim-treesitter-textobjects，可以直接使用
        -- vim.keymap.set({ 'n', 'x', 'o' }, 'w', non_ascii.w, { desc = 'Next word' })
        -- vim.keymap.set({ 'n', 'x', 'o' }, 'b', non_ascii.b, { desc = 'Previous word' })
        -- vim.keymap.set({ 'n', 'x', 'o' }, 'e', non_ascii.e, { desc = 'Next end word' })
        -- vim.keymap.set({ 'n', 'x', 'o' }, 'ge', non_ascii.ge, { desc = 'Previous end word' })
        vim.keymap.set({ 'n', 'x', 'o' }, 'iw', non_ascii.iw, { desc = 'Inside a word' })
    end,
}
