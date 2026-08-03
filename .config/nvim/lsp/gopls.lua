return {
    root_markers = { 'go.work', 'go.mod', '.git' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl', 'gohtmltmpl', 'gotexttmpl' },
    settings = {
        gopls = {
            gofumpt = true,
            completeUnimported = true,
            usePlaceholders = true,
            staticcheck = true,
            vulncheck = 'Imports',
            analyses = {
                nilness = true,
                shadow = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
            },
            codelenses = {
                generate = true,
                gc_details = true,
                regenerate_cgo = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
            },
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
            directoryFilters = { '-.git', '-node_modules', '-vendor' },
            semanticTokens = false,
        },
    },
    on_attach = function(_, buf)
        if vim.lsp.inlay_hint then vim.lsp.inlay_hint.enable(true, { bufnr = buf }) end
    end,
}
