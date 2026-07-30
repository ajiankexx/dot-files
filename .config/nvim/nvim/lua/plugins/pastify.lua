-- return {
--     'ajiankexx/pastify.nvim',
--     event = 'VeryLazy',
--     keys = {
--         {
--             '<cmd>Pastify<cr>',
--             mode = { 'i', 'n' },
--             desc = 'Paste image from system clipboard'
--         },
--     },
--     cmd = { 'Pastify'},
--     ft = vim.g.markdown_support_filetype,
--     config = function()
--         require('pastify').setup {
--             opts = {
--                 filename = function() return vim.fn.expand("%:t:r") .. '_' .. os.date('%Y-%m-%d_%H-%M-%S') end,
--                 local_path = '/.assets/',
--                 save = 'local',
--             },
--             ft = {
--                 markdown = '![]($IMG$)(<++>){: .img-fluid}',
--             }
--         }
--     end
-- }

-- Below is a wrong config.
-- return {
--     'ajiankexx/pastify.nvim',
--     opts = {
--         absolute_path = true,
--         local_path = '/.assets/',
--         save = 'local',
--         filename = function() return vim.fn.expand('%:t:r')..'_'..os.date('%Y-%m-%d_%H-%M-%S') end,
--     },
--     ft = {
--         markdown = '![]($IMG)(<++>){: .img-fluid}',
--     },
--     event = 'VeryLazy',
--     cmd = { 'Pastify' },
-- }

-- Refer to: https://github.com/TobinPalmer/pastify.nvim
return {
  'ajiankexx/pastify.nvim',
  cmd = { 'Pastify' },
  event = 'VeryLazy',
  ft = vim.g.markdown_support_filetype,
  config = function()
    require('pastify').setup {
      opts = {
        absolute_path = false,
        filename = function() return vim.fn.expand("%:t:r")..'_'..os.date('%Y-%m-%d_%H-%M-%S') end,
        local_path = '/.assets/',
        save = 'local_file',
      },
      ft = {
                markdown = '![]($IMG$)\n<++>',
            }
    }
  end
}

