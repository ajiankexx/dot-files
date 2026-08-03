return {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
        'mason-org/mason.nvim',
        'neovim/nvim-lspconfig',
    },
    opts = {
        automatic_installation = false,
        -- LSP activation is configured explicitly in lsp_config.lua so
        -- non-Mason servers continue to work as well.
        automatic_enable = false,
        ensure_installed = {
            'clangd',
            'pyright',
            'jdtls',
            'volar', -- vue
            'ts_ls', -- typescript
            'eslint', -- javascript
            'tailwindcss', -- css
            'bashls',
            'lua_ls',
            'neocmake',
            'jsonls',
            'lemminx', -- xml lsp
            'yamlls',
            'gopls',
            'rust_analyzer',
        },
    }
}
