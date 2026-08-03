return {
    'mason-org/mason.nvim',
    config = function()
        require('mason').setup({
            -- Keep system tools ahead of Mason-installed tools, matching the
            -- previous configuration without hard-coding a data directory.
            PATH = 'append',
        })
        -- Tool installation is asynchronous and should not be started by a
        -- headless command (for example a CI check or `nvim --headless`).
        if #vim.api.nvim_list_uis() == 0 then return end
        local mason_plugins = {
            'bash-language-server',
            'clangd',
            'shellcheck',
            'clang-format',
            'jdtls',
            'java-debug-adapter',
            'java-test',
            'google-java-format',
            'lua-language-server',
            'stylua',
            'pyright',
            'autopep8',
            'markdown-oxide',
            'eslint-lsp',
            'json-lsp',
            'lemminx',
            'neocmakelsp',
            'tailwindcss-language-server',
            'typescript-language-server',
            'vue-language-server',
            'yaml-language-server',
            'prettier',
            'buildifier',
            'bazelrc-lsp',
            -- Go tooling used by go.nvim.
            'delve',
            'gofumpt',
            'goimports',
            'golangci-lint',
            'gomodifytags',
            'gotests',
            'gotestsum',
            'iferr',
            'impl',
        }
        local mason_registry = require('mason-registry')
        -- Mason v2 loads its registry asynchronously. Refresh it before
        -- looking up packages so a fresh installation cannot fail at startup.
        mason_registry.refresh(function()
            for _, plugin in ipairs(mason_plugins) do
                local ok, mason_package = pcall(mason_registry.get_package, plugin)
                if ok and not mason_package:is_installed() then mason_package:install() end
            end
        end)
    end
}
