vim.o.loadplugins = false
vim.opt.runtimepath:prepend(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h'))
vim.g.mapleader = ' '
vim.o.timeoutlen = 400

local keymap = vim.keymap
keymap.set('n', '<leader>ws', '<Cmd>split<CR>', { desc = 'Split window horizontally' })
keymap.set('n', '<leader>wv', '<Cmd>vsplit<CR>', { desc = 'Split window vertically' })
keymap.set('n', '<leader>bd', '<Cmd>bdelete<CR>', { desc = 'Delete buffer' })
keymap.set('n', '<leader>t', '<Cmd>tabnew<CR>', { desc = 'Open new tab' })

require('which_key').setup {
	groups = {
		['<leader>w'] = 'Windows',
		['<leader>b'] = 'Buffers',
	},
}
