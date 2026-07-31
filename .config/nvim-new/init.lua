require('core')
require('key_mapping')
require('markdown_support')
require('line_wise')
require('package_manager')
require('lazy').setup({
    spec = require('plugins'),
    checker = { enabled = false },
    change_detection = { enabled = false },
    performance = {
        rtp = {
            disabled_plugins = {
                'gzip',
                'tarPlugin',
                'tohtml',
                'tutor',
                'zipPlugin',
            },
        },
    },
})
require('debug')
