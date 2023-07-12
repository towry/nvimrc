--LuaCC code block

require("user.plugins.essential")
--- basic
require("user.plugins.theme")
require("user.plugins.cmdline")
require("user.plugins.autocmp")
require("user.plugins.debugger")
require("user.plugins.folding")
require("user.plugins.indent")
require("user.plugins.lsp")
require("user.plugins.statusline")
require("user.plugins.finder")
require("user.plugins.git")
require("user.plugins.terminal")
require("user.plugins.lang")
require("user.plugins.ui")
require("user.plugins.motion")
require("user.plugins.workflow")
--- extras
-- make neovim slow.
-- require("plugin-extras.coding.copilot-nvim")
require("plugin-extras.coding.word-switch")
require("plugin-extras.workflow.zenmode")
-- require("plugin-extras.workflow.mini-files")
require("plugin-extras.workbench.dashboard.mini-starter")
require("plugin-extras.workflow.cheatsheets")
require("plugin-extras.tools.profile")
require("plugin-extras.tools.games")

return require('userlib.runtime.pack').repos()
