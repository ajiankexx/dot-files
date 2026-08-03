local go_filetypes = { 'go', 'gomod', 'gowork', 'gotmpl', 'gohtmltmpl', 'gotexttmpl' }

local function format_go_buffer(buf)
    local clients = vim.lsp.get_clients({ bufnr = buf, name = 'gopls' })
    local client = clients[1]
    if not client then return end

    local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
    params.context = { only = { 'source.organizeImports' }, diagnostics = {} }
    local ok, response = pcall(
        client.request_sync,
        client,
        'textDocument/codeAction',
        params,
        2000,
        buf
    )
    if not ok then response = nil end
    for _, action in ipairs(response and response.result or {}) do
        if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
        end
        local command = type(action.command) == 'table' and action.command or action
        if type(command.command) == 'string' then client:exec_cmd(command, { bufnr = buf }) end
    end

    pcall(vim.lsp.buf.format, {
        bufnr = buf,
        name = 'gopls',
        async = false,
        timeout_ms = 2000,
    })
end

local function attach_go_keymaps(buf)
    local map_set = require('utils').map_set
    local opts = function(desc) return { buffer = buf, desc = desc } end

    map_set('n', '<leader>Gr', '<cmd>GoRun<cr>', opts('Go run'))
    map_set('n', '<leader>Gb', '<cmd>GoBuild<cr>', opts('Go build'))
    map_set('n', '<leader>Gt', '<cmd>GoTestFunc<cr>', opts('Go test nearest'))
    map_set('n', '<leader>Gf', '<cmd>GoTestFile<cr>', opts('Go test file'))
    map_set('n', '<leader>GT', '<cmd>GoTestPkg<cr>', opts('Go test package'))
    map_set('n', '<leader>Gc', '<cmd>GoCoverage -p<cr>', opts('Go package coverage'))
    map_set('n', '<leader>Gx', '<cmd>GoDebug -n<cr>', opts('Go debug nearest'))
    map_set('n', '<leader>Ga', '<cmd>GoAlt<cr>', opts('Go alternate file'))
    map_set('n', '<leader>Gi', '<cmd>GoImpl<cr>', opts('Go implement interface'))
    map_set('n', '<leader>Gs', '<cmd>GoFillStruct<cr>', opts('Go fill struct'))
    map_set('n', '<leader>Ge', '<cmd>GoIfErr<cr>', opts('Go add if err'))
    map_set({ 'n', 'x' }, '<leader>Gj', '<cmd>GoAddTag json<cr>', opts('Go add JSON tags'))
    map_set('n', '<leader>Gd', '<cmd>GoDoc<cr>', opts('Go documentation'))
    map_set('n', '<leader>Gm', '<cmd>GoModTidy<cr>', opts('Go mod tidy'))
    map_set('n', '<leader>Gv', '<cmd>GoVulnCheck<cr>', opts('Go vulnerability check'))
end

return {
    'ray-x/go.nvim',
    ft = go_filetypes,
    dependencies = {
        'ray-x/guihua.lua',
        'neovim/nvim-lspconfig',
        'mfussenegger/nvim-dap',
    },
    opts = {
        -- gopls, diagnostics, DAP UI and Treesitter mappings are managed elsewhere.
        lsp_cfg = false,
        lsp_keymaps = false,
        diagnostic = false,
        textobjects = false,
        lsp_inlay_hints = { enable = false },
        dap_debug = true,
        dap_debug_keymap = false,
        dap_debug_gui = false,
        dap_debug_vt = false,

        -- Keep go.nvim's useful Go-specific integrations.
        lsp_codelens = true,
        lsp_impl = {
            enable = true,
            prefix = 'implemented by: ',
            prefix_highlight = 'DiagnosticInfo',
            separator = ', ',
            highlight = 'DiagnosticOk',
        },
        goimports = 'gopls',
        gofmt = 'gopls',
        fillstruct = 'gopls',
        tag_options = 'json=omitempty',
        test_runner = 'go',
        run_in_floaterm = true,
    },
    config = function(_, opts)
        require('go').setup(opts)

        local keymap_group = vim.api.nvim_create_augroup('GoNvimKeymaps', { clear = true })
        vim.api.nvim_create_autocmd('FileType', {
            group = keymap_group,
            pattern = go_filetypes,
            callback = function(args) attach_go_keymaps(args.buf) end,
        })

        -- lazy.nvim loads this plugin in response to FileType, after that event has fired.
        if vim.tbl_contains(go_filetypes, vim.bo.filetype) then attach_go_keymaps(0) end

        local format_group = vim.api.nvim_create_augroup('GoNvimFormat', { clear = true })
        vim.api.nvim_create_autocmd('BufWritePre', {
            group = format_group,
            pattern = '*.go',
            callback = function(args) format_go_buffer(args.buf) end,
            desc = 'Format Go and organize imports with gopls',
        })
    end,
}
