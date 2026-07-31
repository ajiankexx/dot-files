vim.g.matchup_matchparen_offscreen = { method = 'popup' }

local select_keymaps = {
    ['af'] = { '@function.outer', 'Around function' },
    ['if'] = { '@function.inner', 'Inside function' },
    ['ac'] = { '@class.outer', 'Around class' },
    ['ic'] = { '@class.inner', 'Inside class' },
    ['al'] = { '@loop.outer', 'Around loop' },
    ['il'] = { '@loop.inner', 'Inside loop' },
    ['ab'] = { '@block.outer', 'Around block' },
    ['ib'] = { '@block.inner', 'Inside block' },
    ['ar'] = { '@return.outer', 'Around return' },
    ['ir'] = { '@return.inner', 'Inside return' },
    ['ap'] = { '@parameter.outer', 'Around parameter' },
    ['ip'] = { '@parameter.inner', 'Inside parameter' },
    ['ai'] = { '@conditional.outer', 'Around if' },
    ['ii'] = { '@conditional.inner', 'Inside if' },
}

local move_next_start = {
    [']f'] = { '@function.outer', 'Next function start' },
    [']c'] = { '@class.outer', 'Next class start' },
    [']l'] = { '@loop.outer', 'Next loop start' },
    [']b'] = { '@block.outer', 'Next block start' },
    [']r'] = { '@return.outer', 'Next return start' },
    [']p'] = { '@parameter.inner', 'Next parameter start' },
    [']i'] = { '@conditional.outer', 'Next if start' },
}

local move_next_end = {
    [']F'] = { '@function.outer', 'Next function end' },
    [']C'] = { '@class.outer', 'Next class end' },
    [']L'] = { '@loop.outer', 'Next loop end' },
    [']B'] = { '@block.outer', 'Next block end' },
    [']R'] = { '@return.outer', 'Next return end' },
    [']P'] = { '@parameter.inner', 'Next parameter end' },
    [']I'] = { '@conditional.outer', 'Next if end' },
}

local move_prev_start = {
    ['[f'] = { '@function.outer', 'Previous function start' },
    ['[c'] = { '@class.outer', 'Previous class start' },
    ['[l'] = { '@loop.outer', 'Previous loop start' },
    ['[b'] = { '@block.outer', 'Previous block start' },
    ['[r'] = { '@return.outer', 'Previous return start' },
    ['[p'] = { '@parameter.inner', 'Previous parameter start' },
    ['[i'] = { '@conditional.outer', 'Previous if start' },
}

local move_prev_end = {
    ['[F'] = { '@function.outer', 'Previous function end' },
    ['[C'] = { '@class.outer', 'Previous class end' },
    ['[L'] = { '@loop.outer', 'Previous loop end' },
    ['[B'] = { '@block.outer', 'Previous block end' },
    ['[R'] = { '@return.outer', 'Previous return end' },
    ['[P'] = { '@parameter.inner', 'Previous parameter end' },
    ['[I'] = { '@conditional.outer', 'Previous if end' },
}

local swap_next = {
    ['snf'] = { '@function.outer', 'Swap with next function' },
    ['snc'] = { '@class.outer', 'Swap with next class' },
    ['snl'] = { '@loop.outer', 'Swap with next loop' },
    ['snb'] = { '@block.outer', 'Swap with next block' },
    ['snr'] = { '@return.outer', 'Swap with next return' },
    ['snp'] = { '@parameter.inner', 'Swap with next parameter' },
    ['sni'] = { '@conditional.outer', 'Swap with next if' },
}

local swap_prev = {
    ['spf'] = { '@function.outer', 'Swap with previous function' },
    ['spc'] = { '@class.outer', 'Swap with previous class' },
    ['spl'] = { '@loop.outer', 'Swap with previous loop' },
    ['spb'] = { '@block.outer', 'Swap with previous block' },
    ['spr'] = { '@return.outer', 'Swap with previous return' },
    ['spp'] = { '@parameter.inner', 'Swap with previous parameter' },
    ['spi'] = { '@conditional.outer', 'Swap with previous if' },
}


return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    dependencies = {
        {
            'andymass/vim-matchup',
            config = true,
        },
        {
            'nvim-treesitter/nvim-treesitter-textobjects',
            config = function()
                local map_set = require('utils').map_set
                local ts_select = require('nvim-treesitter-textobjects.select')
                local ts_move = require('nvim-treesitter-textobjects.move')
                local ts_swap = require('nvim-treesitter-textobjects.swap')
                local ts_repeat_move = require('nvim-treesitter-textobjects.repeatable_move')


                for key, spec in pairs(select_keymaps) do
                    local query, desc = spec[1], spec[2]
                    map_set({ 'x', 'o' }, key, function()
                        ts_select.select_textobject(query)
                    end, { desc = desc })
                end

                for key, spec in pairs(move_next_start) do
                    local query, desc = spec[1], spec[2]
                    map_set('n', key, function() ts_move.goto_next_start(query) end, { desc = desc })
                end
                for key, spec in pairs(move_next_end) do
                    local query, desc = spec[1], spec[2]
                    map_set('n', key, function() ts_move.goto_next_end(query) end, { desc = desc })
                end
                for key, spec in pairs(move_prev_start) do
                    local query, desc = spec[1], spec[2]
                    map_set('n', key, function() ts_move.goto_previous_start(query) end, { desc = desc })
                end
                for key, spec in pairs(move_prev_end) do
                    local query, desc = spec[1], spec[2]
                    map_set('n', key, function() ts_move.goto_previous_end(query) end, { desc = desc })
                end

                for key, spec in pairs(swap_next) do
                    local query, desc = spec[1], spec[2]
                    map_set('n', key, function() ts_swap.swap_next(query) end, { desc = desc })
                end
                for key, spec in pairs(swap_prev) do
                    local query, desc = spec[1], spec[2]
                    map_set('n', key, function() ts_swap.swap_previous(query) end, { desc = desc })
                end

                local feedkeys = require('utils').feedkeys
                local next_misspell, prev_misspell = require('utils').make_repeatable_move_pair(
                    function() feedkeys(']s', 'n') end,
                    function() feedkeys('[s', 'n') end
                )
                local next_big_word, prev_big_word = require('utils').make_repeatable_move_pair(
                    function() feedkeys('W', 'n') end,
                    function() feedkeys('B', 'n') end
                )
                local next_search, prev_search = require('utils').make_repeatable_move_pair(
                    function()
                        vim.g.snacks_animate_scroll = false
                        feedkeys('n', 'n')
                        vim.schedule(function() vim.g.snacks_animate_scroll = true end)
                    end,
                    function()
                        vim.g.snacks_animate_scroll = false
                        feedkeys('N', 'n')
                        vim.schedule(function() vim.g.snacks_animate_scroll = true end)
                    end
                )
                map_set({ 'n', 'x' }, 'n', next_search, { desc = 'Next search pattern' })
                map_set({ 'n', 'x' }, 'N', prev_search, { desc = 'Previous search pattern' })
                map_set('n', 'W', next_big_word, { desc = 'Next big word' })
                map_set('n', 'B', prev_big_word, { desc = 'Previous big word' })
                map_set('n', ']s', next_misspell, { desc = 'Next misspelled word' })
                map_set('n', '[s', prev_misspell, { desc = 'Previous misspelled word' })
                map_set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next, { desc = 'Repeat last textobject move' })
                map_set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_previous, { desc = 'Repeat last textobject move opposite' })
            end,
        },
        {
            'nvim-treesitter/nvim-treesitter-context',
            opts = {
                max_lines = 1,
                on_attach = function(buf)
                    vim.b[buf].matchup_matchparen_enabled = 0
                    return true
                end,
            },
        },
    },
    config = function()
        vim.api.nvim_create_autocmd('FileType', {
            pattern = '*',
            callback = function(args)
                pcall(vim.treesitter.start, args.buf)
            end,
        })
        vim.o.foldmethod = 'expr'
        vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end,
}
