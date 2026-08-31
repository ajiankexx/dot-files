return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'aznhe21/actions-preview.nvim',
        {

            'mfussenegger/nvim-jdtls',
            dependencies = {
                'mfussenegger/nvim-dap',
            },
        },
    },
    config = function()
        vim.lsp.config('*', {
            capabilities = require('utils').get_lsp_capabilities(),
            root_markers = vim.g.root_markers,
        })
        -- sourcekit-lsp also advertises C/C++ support, but clangd provides the
        -- dedicated C/C++ integration below. Restrict SourceKit to Swift so a
        -- C/C++ buffer does not start two language servers.
        vim.lsp.config('sourcekit', {
            filetypes = { 'swift' },
        })
        vim.lsp.enable({
            'bashls',
            'clangd',
            'dartls',
            'eslint',
            'jsonls',
            'kotlin_language_server',
            'lemminx',
            'lua_ls',
            'neocmake',
            'pyright',
            'tailwindcss',
            'ts_ls',
            'vue_ls',
            'yamlls',
            'markdown_oxide',
            'gopls',
            'rust_analyzer',
            'sourcekit',
        })
        local map_set = require('utils').map_set
        map_set(
            { 'v', 'n' },
            'ga',
            require('actions-preview').code_actions,
            { desc = 'Code action' }
        )
    end,
}
