-- make gf work better.
vim.cmd([[setlocal suffixesadd+=.js,.ts,.scss,tsx,.jsx,.vue,.html]])
vim.cmd('setlocal path+=src')
vim.opt_local.commentstring = [[<!--%s-->]]

require('user.ftplugins.css').attach({
  ft = 'vue',
})
